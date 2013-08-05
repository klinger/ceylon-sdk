import ceylon.net.http { Method }
abstract shared class EndpointBase(path) {
    shared Matcher path;
}

abstract shared class HttpEndpoint(Matcher path, acceptMethod) extends EndpointBase(path) {
    shared {Method*} acceptMethod;
}
