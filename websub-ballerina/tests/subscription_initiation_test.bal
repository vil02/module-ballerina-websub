// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;
import ballerina/http;

const string CALLBACK = "https://sample.subscriber.com/subscriber";
const string DISCOVERY_SUCCESS_URL = "http://127.0.0.1:9192/common/discovery";
const string DISCOVERY_FAILURE_URL = "http://127.0.0.1:9192/common/failed";
const string HUB_SUCCESS_URL = "http://127.0.0.1:9192/common/hub";
const string HUB_FAILURE_URL = "http://127.0.0.1:9192/common/failed";
const string COMMON_TOPIC = "https://sample.topic.com";

service /common on new http:Listener(9192) {
    isolated resource function get discovery(http:Caller caller, http:Request request) {
        http:Response response = new;
        response.addHeader("Link", "<http://127.0.0.1:9192/common/hub>; rel=\"hub\"");
        response.addHeader("Link", "<https://sample.topic.com>; rel=\"self\"");
        http:ListenerError? resp = caller->respond(response);
    }

    isolated resource function post hub(http:Caller caller, http:Request request) {
        http:ListenerError? resp = caller->respond();
    }
}

isolated function getServiceConfig(string|[string, string] target) returns SubscriberServiceConfiguration {
    return {
        target: target,
        leaseSeconds: 36000,
        callback: CALLBACK
    };
}

@test:Config { 
    groups: ["subscriptionInitiation"]
}
isolated function testSubscriptionInitiationSuccessWithDiscoveryUrl() returns @tainted error? {
    SubscriberServiceConfiguration config = getServiceConfig(DISCOVERY_SUCCESS_URL);
    check initiateSubscription(config, CALLBACK);
}

@test:Config { 
    groups: ["subscriptionInitiation"]
}
isolated function testSubscriptionInitiationSuccessWithHubAndTopic() returns @tainted error? {
    SubscriberServiceConfiguration config = getServiceConfig([ HUB_SUCCESS_URL, COMMON_TOPIC ]);
    check initiateSubscription(config, CALLBACK);
}

@test:Config { 
    groups: ["subscriptionInitiation"]
}
isolated function testSubscriptionInitiationFailureWithDiscoveryUrl() returns @tainted error? {
    SubscriberServiceConfiguration config = getServiceConfig(DISCOVERY_FAILURE_URL);
    var response = initiateSubscription(config, CALLBACK);
    test:assertTrue(response is ResourceDiscoveryFailedError);
}

@test:Config { 
    groups: ["subscriptionInitiation"]
}
isolated function testSubscriptionInitiationFailureWithHubAndTopic() returns @tainted error? {
    SubscriberServiceConfiguration config = getServiceConfig([ HUB_FAILURE_URL, COMMON_TOPIC ]);
    var response = initiateSubscription(config, CALLBACK);
    test:assertTrue(response is SubscriptionInitiationError);
}

