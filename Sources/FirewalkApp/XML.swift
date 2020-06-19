//
//  XML.swift
//
//
//  Created by Jon Shier on 5/3/20.
//

import Vapor

func createXMLRoute(for app: Application) throws {
    app.on(.GET, "xml") { request -> Response in
        let body = """
        <?xml version='1.0' encoding='us-ascii'?>
        <!--  A SAMPLE set of slides  -->
        <slideshow
          title="Sample Slide Show"
          date="Date of publication"
          author="Yours Truly"
          >
          <!-- TITLE SLIDE -->
          <slide type="all">
            <title>Wake up to WonderWidgets!</title>
          </slide>
          <!-- OVERVIEW -->
          <slide type="all">
            <title>Overview</title>
            <item>
              Why
              <em>WonderWidgets</em>
               are great
            </item>
            <item/>
            <item>
              Who
              <em>buys</em>
               WonderWidgets
            </item>
          </slide>
        </slideshow>
        """

        var buffer = request.application.allocator.buffer(capacity: body.utf8.count)
        buffer.writeString(body)

        let response = Response(body: .init(buffer: buffer))
        response.headers.replaceOrAdd(name: .contentType, value: "application/xml")
        return response
    }
}
