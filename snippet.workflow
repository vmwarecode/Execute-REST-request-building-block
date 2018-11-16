// VMware vRealize Orchestrator action sample - "executeRestRequest"
//
// Execute API calls against target REST Host directly by providing the high level inputs.
// Action takes care of formulating the request object and executing the request, capturing errors, and JSON <-> JavaScript object translation (inputs are JS objects, outputs are JS objects);
// Finds the REST Host dynamically and constructs the full url and an adhoc REST Operation.
//
// restHostName - string - RESTHost name (must exist in Inventory by this name)
// method - string - HTTP Method ("GET", "POST", etc)
// operation - string - Operation URL ("/networks/192.168.1.0")
// body - Any - JavaScript object (will be serialized for the body)
// additionalHeaders - Properties- Additional Headers to apply to the request (such as Authentication)
//
// Return type: Any (JavaScript object, ie: deserialized JSON response)
//

var request = createRequest(restHostName, method, operation, body, additionalHeaders);
var content = executeRequest(request, restHostName);

return getResult(content);

/////////////////////////////////////////////////////////////////////////////////////////////////////
function createRequest(restHostName, method, operation, body, additionalHeaders) {
	var restHost = getRestHostByName(restHostName);
	
	var request = restHost.createRequest(method, operation, getBodyJson(body));
	addHeaders(request, additionalHeaders);
		
	System.debug("    Request: " + request);
	System.debug("    Request URL: " + request.fullUrl);

	return request;
}

function addHeaders(request, additionalHeaders) {
	request.contentType = "application/json";
	request.setHeader("Accept", "application/json");
	
	for each (var key in additionalHeaders.keys) {
		var value = additionalHeaders.get(key);
		System.debug("additionalHeaders = " + key + " : " + value);
		request.setHeader(key, value);
	}
}

function executeRequest(request, restHostName) {
	var response = request.execute();
	var contentAsString = response.contentAsString;
	var statusCode = response.statusCode;
	System.debug("    Status Code: " + statusCode);
	System.debug("    Response: " + contentAsString);
	
	if (parseInt(statusCode) >= 400) {
		throw "Error while requesting from the REST host " + restHostName + " and the url " +  request.fullUrl 
				+ " (Status Code " + statusCode + "):" + contentAsString;
	}
	
	return contentAsString;
}


function getBodyJson(body) {
	if (body == null) {
		return null;
	}
	var bodyJSON = JSON.stringify(body);
	System.debug("JS body: " + bodyJSON);
	return bodyJSON;
}

function getRestHostByName(restHostName) {
	var allHosts = Server.findAllForType("REST:RESTHost", null);

	System.debug("Finding REST Host by name '" + name + "'");

	for each (var host in allHosts) {
		if (host.name == restHostName) {
			System.debug("Found REST Host '" + name + "'!");
			return host;
		}
	}

	throw "Unable to find a REST:Host with the name " + name;
}


function getResult(content) {
	if (isEmpty(content)) {
		return null;
	}
	var result = JSON.parse(content);
	System.debug("response JSON: " + JSON.stringify(result, null, 4));
	return result;
}

function isEmpty(input) {
	return input == null || input == "";
}
