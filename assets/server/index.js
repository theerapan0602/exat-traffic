//https://www.digitalocean.com/community/tutorials/how-to-set-up-a-node-js-application-for-production-on-ubuntu-18-04

const express = require('express');
const app = express();
const http = require('http').createServer(app);
const io = require('socket.io')(http);
const mysql = require('mysql');
const cronJob = require("cron").CronJob;
const fetch = require('node-fetch');

const CODE_FAILED = 1;
const CODE_SUCCESS = 0;

const routeIdList = [1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];

app.use(express.static('./'));

// Add headers
app.use(function (req, res, next) {

  // Website you wish to allow to connect
  //res.setHeader('Access-Control-Allow-Origin', 'http://localhost:8080');
  res.setHeader('Access-Control-Allow-Origin', '*');

  // Request methods you wish to allow
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');

  // Request headers you wish to allow
  res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type');

  // Set to true if you need the website to include cookies in the requests sent
  // to the API (e.g. in case you use sessions)
  res.setHeader('Access-Control-Allow-Credentials', true);

  // Pass to next layer of middleware
  next();
});

//ENABLE CORS
app.all('/', function (req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "X-Requested-With");
  next();
});

/*app.get('/', function (req, res) {
    //res.sendFile(__dirname + '/index.html');
    res.send('<h1>Socket.IO Server is Running.</h1>');
});*/

/*app.get('/demo', function (req, res) {
    res.sendFile(__dirname + '/connection_visualization_new.html');
});*/

app.get('/location', function (req, res) {
  const {lat, lng, type} = req.query;
  if (lat == null || lng == null || type == null) {
    res.json({error: {code: 1, message: 'ส่งพารามิเตอร์มาไม่ครบ ต้องมี lat, lng, type'}});
    return;
  }

  const latValue = parseFloat(lat);
  const lngValue = parseFloat(lng);
  if (isNaN(latValue) || isNaN(lngValue)) {
    res.json({error: {code: 2, message: 'พารามิเตอร์ lat หรือ lng ไม่ใช่ตัวเลข'}});
    return;
  }
  if (latValue > 90 || latValue < -90 || lngValue > 180 || lngValue < -180) {
    res.json({error: {code: 3, message: 'ค่าของพารามิเตอร์ lat หรือ lng เกินขอบเขต (lat ต้องอยู่ในช่วง -90 ถึง 90, lng ต้องอยู่ในช่วง -180 ถึง 180)'}});
    return;
  }
  const validTypes = ['inuse', 'bg']
  if (!validTypes.includes(type.toString().toLowerCase())) {
    res.json({error: {code: 4, message: 'พารามิเตอร์ type ไม่ถูกต้อง, ต้องมีค่า inuse หรือ bg เท่านั้น'}});
    return;
  }

  console.log(`Latitude: ${lat}, Longitude: ${lng}`);
  io.emit('location', {lat: latValue, lng: lngValue, type});
  res.json({error: {code: 0, message: 'success: ยิงข้อมูล lat, lng ไปยังหน้าเว็บ Visualization สำเร็จ'}});
});

io.on('connection', function (socket) {
  console.log('client connected');

  fetchData();

  socket.on('disconnect', function () {
    console.log('client disconnected');
  });
});

app.get('/api/route_traffic', (req, res) => {
  const promiseList = [];

  // เอาเฉพาะสายทางของ exat
  [1, 3, 4, 5, 6, 7, 8, 10].forEach(routeId => {
    const promise = fetch('https://alg.exat.co.th/api/roads/' + routeId, {
      method: 'get',
      headers: {'Authorization': 'Token 8a4e96ed4c9281af4d0c2189c6a72551fe940b43'},
    })
      .then(result => result.json())
      .then(result => result[0].chunks);

    promiseList.push(promise);
  })

  Promise.all(promiseList).then(resultList => {
    const allRouteChunks = resultList.reduce((total, chunks) => {
      return total.concat(chunks.map(chunk => {
          return {
            id: chunk.chunk_id,
            idx: chunk.traffic_index
          };
        })
      );
    }, []);

    console.log(allRouteChunks);
    //io.emit('update-traffic', allRouteChunks);
    res.json({
      error: {
        code: CODE_SUCCESS,
        message: 'ok',
      },
      data_list: allRouteChunks,
    });
  });
});

app.get('/api/:item/:id?', (req, res) => {
    const connection = mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: 'Exf@2020ch5U$m#2kh&Mc[XY',
      database: 'itsexat2020'
    });
    connection.connect();

    /*connection.connect(function(err) {
      if (err) {
        res.json({
          error: {
            code: 1,
            message: 'เกิดข้อผิดพลาดในการเชื่อมต่อฐานข้อมูล',
          },
          data_list: null,
        });
        return;
      }
      console.log('connected as id ' + connection.threadId);
    });*/

    let whereClause;
    switch (req.params.item) {
      case 'user_tracking':
        res.json({
          error: {
            code: CODE_SUCCESS,
            message: 'บันทึกข้อมูลสำเร็จ',
          },
          data_list: null,
        });
        connection.end();
        break;

      case 'gate_in':
        whereClause = req.params.id == null ? 'true' : `gi.route_id = ${req.params.id}`;
        connection.query(
          `SELECT temp.route_name, 
                    temp.route_id AS gate_in_route_id, 
                    temp.gate_in_id,
                    temp.name AS gate_in_name,
                    temp.marker_id,
                    m.route_id as marker_route_id,
                    m.name AS marker_name,
                    m.cate_id,
                    m.lat,
                    m.lng,
                    m.enable,
                    temp.cost_tolls_count
             FROM (
                 SELECT gi.route_id, r.name AS route_name, ct.gate_in_id, gi.name, gi.marker_id, COUNT(ct.gate_in_id) AS cost_tolls_count
                   FROM cost_tolls ct
                            INNER JOIN gate_in gi ON ct.gate_in_id = gi.id 
                            INNER JOIN routes r ON gi.route_id = r.id
                   WHERE ${whereClause} 
                   GROUP BY ct.gate_in_id) AS temp
                      INNER JOIN markers m ON temp.marker_id = m.id
             ORDER BY temp.route_id, temp.gate_in_id`,
          (error, results, fields) => {
            if (error) {
              res.json({
                error: {
                  code: CODE_FAILED,
                  message: 'เกิดข้อผิดพลาดในการดึงข้อมูล',
                },
                data_list: null,
              });
            } else {
              res.json({
                error: {
                  code: CODE_SUCCESS,
                  message: 'ok',
                },
                data_list: results,
              });
            }
          });
        connection.end();
        break;

      case 'cost_toll_by_gate_in':
        whereClause = req.params.id == null ? 'true' : `ct.gate_in_id = ${req.params.id}`;
        connection.query(
          `SELECT ct.id,
                    m.name,
                    m.lat,
                    m.lng,
                    m.cate_id,
                    m.route_id,
                    r.name AS route_name,
                    ct.part_toll,
                    ct.cost_less4,
                    ct.cost_4to10,
                    ct.cost_over10
             FROM cost_tolls ct
                      INNER JOIN markers m ON ct.marker_id = m.id
                      INNER JOIN routes r ON m.route_id = r.id 
             WHERE ${whereClause} 
             ORDER BY route_id`,
          (error, results, fields) => {
            if (error) {
              res.json({
                error: {
                  code: CODE_FAILED,
                  message: 'เกิดข้อผิดพลาดในการดึงข้อมูล',
                },
                data_list: null,
              });
              connection.end();
            } else {
              //results['part_toll_list'] = [];
              const allPartTollIdList = [];

              results.forEach(costToll => {
                costToll['part_toll_id'] = [];

                if (costToll['part_toll'] != null) {
                  const partTollList = costToll['part_toll'].split('-');

                  partTollList.forEach(partToll => {
                    const partTollId = parseInt(partToll);
                    costToll['part_toll_id'].push(partTollId);

                    if (!allPartTollIdList.includes(partTollId)) {
                      allPartTollIdList.push(partTollId);
                    }
                  });
                }
              });

              if (allPartTollIdList.length > 0) {
                const partTollIdListCsv = allPartTollIdList.reduce(
                  (total, partTollId) => total == null ? partTollId : `${total}, ${partTollId}`,
                  null
                );

                const sql = `SELECT m.id, m.name, m.lat, m.lng, m.cate_id, m.route_id, r.name AS route_name
                             FROM markers m 
                                 INNER JOIN routes r ON m.route_id = r.id 
                             WHERE m.id IN (${partTollIdListCsv})`;
                connection.query(
                  sql,
                  (error, partTollResults, fields) => {
                    if (error) {
                      res.json({
                        error: {
                          code: CODE_FAILED,
                          message: 'เกิดข้อผิดพลาดในการดึงข้อมูล',
                        },
                        all_part_toll_id: allPartTollIdList,
                        data_list: null,
                      });
                      connection.end();
                    } else {
                      results.forEach(costToll => {
                        const partTollMarkerList = costToll['part_toll_id'].map(partTollId => {
                          const filteredMarkerList = partTollResults.filter(partTollMarker => partTollMarker.id === partTollId);
                          return filteredMarkerList.length > 0 ? filteredMarkerList[0] : null;
                        });
                        costToll['part_toll_markers'] = partTollMarkerList;
                      });

                      res.json({
                        error: {
                          code: CODE_SUCCESS,
                          message: 'ok',
                        },
                        all_part_toll_id: allPartTollIdList,
                        all_part_toll_markers: partTollResults,
                        data_list: results,
                      });
                      connection.end();
                    }
                  }
                );
              } else {
                results.forEach(costToll => {
                  costToll['part_toll_markers'] = [];
                });
                res.json({
                  error: {
                    code: CODE_SUCCESS,
                    message: 'ok',
                  },
                  all_part_toll_id: [],
                  all_part_toll_markers: [],
                  data_list: results,
                });
                connection.end();
              }
            }
          });
        //connection.end();
        break;
    }
  }
);

new cronJob("*/5 * * * *", function () {
  console.log('CRON JOB RUN: ' + new Date());
  fetchData();
}, null, true);

fetchData = () => {
  /*routeIdList.forEach(routeId => {
    fetch('https://alg.exat.co.th/api/roads/' + routeId, {
      method: 'get',
      headers: {'Authorization': 'Token 8a4e96ed4c9281af4d0c2189c6a72551fe940b43'},
    })
      .then(result => result.json())
      .then(emitResult);
  });*/

  const promiseList = [];
  routeIdList.forEach(routeId => {
    const promise = fetch('https://alg.exat.co.th/api/roads/' + routeId, {
      method: 'get',
      headers: {'Authorization': 'Token 8a4e96ed4c9281af4d0c2189c6a72551fe940b43'},
    })
      .then(result => result.json())
      .then(result => result[0].chunks);

    promiseList.push(promise);
  })

  Promise.all(promiseList).then(resultList => {
    const allRouteChunks = resultList.reduce((total, chunks) => {
      return total.concat(chunks.map(chunk => {
          return {
            id: chunk.chunk_id,
            idx: chunk.traffic_index
          };
        })
      );
    }, []);

    console.log(allRouteChunks);
    io.emit('update-traffic', allRouteChunks);
  });
};

http.listen(3000, function () {
  console.log('listening on *:3000');
});
