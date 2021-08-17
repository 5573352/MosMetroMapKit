//
//  ShortRoute.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 06.09.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import Foundation

public struct ShortRoute    : Route {
    public var metadata     : RouteMetadata
    public var from         : Station?
    public var to           : Station?
    var drawMetadata : RouteDrawMetadata
    var edges        : [Edge]
}
