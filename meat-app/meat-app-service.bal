import ballerina/http;
import ballerina/io;
import ballerina/log;

listener http:Listener httpListener = new(9090);

@http:ServiceConfig { 
    basePath: "/meat-app"
}
service meatAppServiceMgt on httpListener {

    int errors = 0;
    int requestCounts = 0;
    

    // Resource that handles the HTTP GET requests that are directed to a specific
    // order using path '/order/<orderId>'
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/restaurants"
    }    
    resource function getAllRestaurants(http:Caller caller, http:Request req) {
        
        io:println("get all restaurants");
        meatAppServiceMgt.requestCounts += 1;
        http:Response res = new;
        string filePath = "./assets/restaurant-data.json";
                
        var rResult = readJsonFile(filePath, "restaurants");
        
        if (rResult is error) {
            res.statusCode = 500;
            log:printError("Error occurred while reading json: ", err = rResult);
        } else {
            res.statusCode = 200;
            res.setPayload(untaint rResult);
         
            var result = caller->respond(res);
            handleErrorWhenResponding(result);
            
        }

        io:println("total requests: ", int.convert(meatAppServiceMgt.requestCounts));
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/restaurant/{restaurantId}"
    }    
    resource function getRestaurantById(http:Caller caller, http:Request req, string restaurantId) {

        io:println("get restaurant: " + restaurantId);
        meatAppServiceMgt.requestCounts += 1;
        http:Response res = new;
        string filePath = "./assets/restaurant-data.json";
        
        var rResult = readJsonFile(filePath, "restaurants");
        
        if (rResult is error) {
            res.statusCode = 500;
            log:printError("Error occurred while reading json: ", err = rResult);
        } else {            
            int i = 0;
            int index = -1;
            while (i < rResult.length()) {
                if (rResult[i].id == restaurantId) {
                    index = i;
                    break;
                }
                i += 1;
            }

            res.statusCode = 200;
            res.setPayload(untaint rResult[index]);
         
            var result = caller->respond(res);
            handleErrorWhenResponding(result);
            
        }

        io:println("total requests: ", int.convert(meatAppServiceMgt.requestCounts));
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/restaurant/{restaurantId}/reviews"
    }    
    resource function getRestaurantReviews(http:Caller caller, http:Request req, string restaurantId) {
        
        io:println("get restaurant reviews for ", restaurantId);
        meatAppServiceMgt.requestCounts += 1;
        http:Response res = new;
        string filePath = "./assets/review-data.json";
        
        var rResult = readJsonFile(filePath, restaurantId);
        
        if (rResult is error) {
            res.statusCode = 500;
            log:printError("Error occurred while reading json: ", err = rResult);
        } else {            
            res.statusCode = 200;
            res.setPayload(untaint rResult);
         
            var result = caller->respond(res);
            handleErrorWhenResponding(result);
            
        }        

        io:println("total requests: ", int.convert(meatAppServiceMgt.requestCounts));

    }

        @http:ResourceConfig {
        methods: ["GET"],
        path: "/restaurant/{restaurantId}/menu"
    }    
    resource function getRestaurantMenu(http:Caller caller, http:Request req, string restaurantId) {
        
        io:println("get restaurant menu for ", restaurantId);
        meatAppServiceMgt.requestCounts += 1;
        http:Response res = new;
        string filePath = "./assets/menu-data.json";
        
        var rResult = readJsonFile(filePath, restaurantId);
        
        if (rResult is error) {
            res.statusCode = 500;
            log:printError("Error occurred while reading json: ", err = rResult);
        } else {            
            res.statusCode = 200;
            res.setPayload(untaint rResult);
         
            var result = caller->respond(res);
            handleErrorWhenResponding(result);
            
        }        

        io:println("total requests: ", int.convert(meatAppServiceMgt.requestCounts));

    }
}

function handleErrorWhenResponding(error? result) {
    if (result is error) {
        log:printError("Error when responding", err = result);
    }
}

function readJsonFile(string path, string data) returns json|error {
    
    io:ReadableByteChannel rbc = io:openReadableFile(path);
    io:ReadableCharacterChannel rch = new(rbc, "UTF8");
    json dataReturn = {};

    json|error jsonReturn = rch.readJson();
    if (jsonReturn is json) {
        var keys = jsonReturn.getKeys();
        foreach var item in keys {
            //io:println("item: ", jsonReturn[data]);
            dataReturn = json.convert(jsonReturn[data]);
        }
    }

    var ioError = rbc.close();
    if (ioError is error) {
        log:printError("Error occurred while closing character stream", err = ioError);
        return ioError;
    } else {
        return dataReturn; 
    }
}

type Restaurant record {
    string id;
    string name;
    string category;
    string deliveryEstimate;
    float rating;
    string imagePath;
    string about;
    string hours;
    Review[] reviews;
    MenuItem[] menu;
};

type MenuItem record {
    string id;
    string imagePath;
    string name;
    string description;
    float price;
    string restaurantId;
};

type Review record {
    string name;
    string date;
    float rating;
    string comments;
    string restaurantId;
};





