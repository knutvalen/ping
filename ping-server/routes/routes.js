let options = {
    token: {
        key: "AuthKey_5258794Z88.p8",
        keyId: "5258794Z88",
        teamId: "52Y2FSFMZD"
    },
    production: false
};

let apn = require('apn');
let apnProvider = new apn.Provider(options);

let appRouter = function (app) {

    app.get("/", function (req, res) {
        res.status(200).send({ message: 'root' });
    });

    app.post("/ping", function (req, res) {
        let username = req.body.username;

        res.status(200).send({
            status: 200,
            message: "ping_" + username,
            ok: true
        });
    });

    app.get("/push", function (req, res) {
        let token = req.headers.token;
        let notification = new apn.Notification();
        notification.contentAvailable = true;
        notification.topic = "no.qassql.ping";

        apnProvider.send(notification, token).then( (result) => {
            console.log(result);
        });

        res.status(200).send({
            status: 200,
            ok: true
        });
    });
};

module.exports = appRouter;