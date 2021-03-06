const express = require('express');

const app = express();

app.use((req, res, next)=>{
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Headers", 
    "Origin, X-Requested-With, Content-Type, Accept, Authorization");
    res.setHeader("Access-Control-Allow-Methods",
    "GET, POST, PATCH, PUT, DELETE, OPTIONS");
    next();
});
app.get('/', (req, res) => {
    res.send('Hi there');
});

app.listen(8080, () => {
    console.log('Listening on port 8080');
});