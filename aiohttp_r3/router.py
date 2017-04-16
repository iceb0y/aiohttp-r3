import asyncio
from aiohttp import web
from aiohttp_r3 import _r3

METHOD_STR_TO_INT = {
    'GET': _r3.METHOD_GET,
    'POST': _r3.METHOD_POST,
    'PUT': _r3.METHOD_PUT,
    'DELETE': _r3.METHOD_DELETE,
    'PATCH': _r3.METHOD_PATCH,
    'HEAD': _r3.METHOD_HEAD,
    'OPTIONS': _r3.METHOD_OPTIONS,
}

METHOD_ALL = (_r3.METHOD_GET | _r3.METHOD_POST | _r3.METHOD_PUT |
              _r3.METHOD_DELETE | _r3.METHOD_PATCH | _r3.METHOD_HEAD |
              _r3.METHOD_OPTIONS)

class R3Router(web.UrlDispatcher):
    def __init__(self):
        super().__init__()
        self.tree = _r3.R3Tree()

    def add_route(self, method, path, handler, *, name=None, expect_handler=None):
        route = super().add_route(
            method, path, handler, name=name, expect_handler=expect_handler)
        if method == '*':
            method_int = METHOD_ALL
        else:
            method_int = METHOD_STR_TO_INT[method]
        self.tree.insert_route(method_int, path.encode(), route)
        return route

    def freeze(self):
        super().freeze()
        self.tree.compile()

    @asyncio.coroutine
    def resolve(self, request):
        route, params = self.tree.match_route(METHOD_STR_TO_INT[request._method],
                                              request.rel_url.raw_path.encode())
        if route:
            match_dict = dict((k.decode(), v.decode()) for k, v in params)
            return web.UrlMappingMatchInfo(match_dict, route)
        result = yield from super().resolve(request)
        return result
