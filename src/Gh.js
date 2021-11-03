const https = require('https');

exports.requestImpl = (opt) => () => {
    const url = "https://api.github.com/graphql"
    const options = {
        method: "POST",
        headers: {
            "Authorization": "bearer " + opt.token,
            "user-agent": "node.js",
        },
        timeout: 3000,
    };
    const req = https.request(url, options, (res) => {
        res.setEncoding("utf8");
        let responseBody = "";
        res.on("data", (chunk) => {
            responseBody = responseBody + chunk.toString();
        })
        res.on("end", () => {
            const statusCode = parseInt(res.statusCode);
            opt.callback(opt.rightf(statusCode)(responseBody))();
        })
    });
    req.on("error", (e) => {
        opt.callback(opt.leftf(e))();
    })
    req.write(opt.body);
    req.end();
};