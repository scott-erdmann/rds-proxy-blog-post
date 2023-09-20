import { Signer } from "@aws-sdk/rds-signer";
import pg from "pg";

const username = "rds_proxy";
const region = "us-east-1";
const database = "rds-proxy-blog-post";
const rdsProxyEndpoint = "demo-rds-proxy.proxy-ckqzn0kh9acb.us-east-1.rds.amazonaws.com";
const port = 5432;

const signer = new Signer({
    hostname: rdsProxyEndpoint,
    port: 5432,
    username: username,
    region: region
});

export const handler = async (event, context) => {
    console.log(event);

    const token = await signer.getAuthToken();

    const config = {
        user: username,
        host: rdsProxyEndpoint,
        database: database,
        password: token,
        port: port,
        ssl: true
    }

    const client = new pg.Client(config);
    await client.connect();

    setTimeout(function() {
        console.log("Done waiting!");
    }, 10000);

    console.log("Successfully connected to the RDS instance with a 10s delay!");

    return {
        statusCode: 200,
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            "key": "value"
        }),
        isBase64Encoded: false
    };
};
