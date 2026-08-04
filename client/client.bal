import ballerina/http;
import ballerina/io;

public function main() returns error? {
    http:Client c = check new ("http://localhost:8080/library");
    json result = check c->get("/assets");
    io:println(result);
}
