//
//  ShortRoute.swift
//
//  Created by Сеня Римиханов on 06.09.2020.
//

import Foundation

struct ShortRoute    : Route {
    public var metadata : RouteMetadata
    public var from     : Station?
    public var to       : Station?
    var drawMetadata    : RouteDrawMetadata
    var edges           : [Edge]
}
