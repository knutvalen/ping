let apnOptions = {
    cert: "cert.pem",
    key: "voip.pem",
    production: false
};

let apn = require('apn');
let apnProvider = new apn.Provider(apnOptions);

let appRouter = function (app) {

    app.get("/", function (req, res) {
        res.status(200).send({ message: 'root' });
    });

    app.post("/ping", function (req, res) {
        let username = req.body.username;
        console.log("ping " + username);

        res.status(200).send({
            status: 200,
            message: "ping_" + username,
            ok: true
        });
    });

    app.get("/push", function (req, res) {
        console.log("push");

        let token = req.headers.token;
        let notification = new apn.Notification();
        notification.contentAvailable = true;

        apnProvider.send(notification, token).then( (result) => {
            if (result.failed.length > 0)
                console.log('push error:', result.failed[0].response);
        });

        res.status(200).send({
            status: 200,
            ok: true
        });
    });
};

module.exports = appRouter;