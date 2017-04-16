cimport cr3
import asyncio
from aiohttp.web_urldispatcher import UrlDispatcher, UrlMappingMatchInfo, MatchInfoError, HTTPNotFound
from libc.stdlib cimport free

METHOD_GET = cr3.METHOD_GET
METHOD_POST = cr3.METHOD_POST
METHOD_PUT = cr3.METHOD_PUT
METHOD_DELETE = cr3.METHOD_DELETE
METHOD_PATCH = cr3.METHOD_PATCH
METHOD_HEAD = cr3.METHOD_HEAD
METHOD_OPTIONS = cr3.METHOD_OPTIONS

cdef inline bytes _iovec_to_bytes(cr3.r3_iovec_t* iovec):
    return iovec.base[:iovec.len]

cdef class R3Tree:
    cdef cr3.R3Node* root
    cdef list objects

    def __cinit__(self):
        self.root = cr3.r3_tree_create(10)
        self.objects = list()

    def __dealloc__(self):
        cr3.r3_tree_free(self.root)

    def insert_route(self, int method, bytes path, obj):
        self.objects.append(path)
        self.objects.append(obj)
        cr3.r3_tree_insert_routel(self.root, method, path, len(path), <void*>obj)

    def compile(self):
        cdef char* errstr
        if cr3.r3_tree_compile(self.root, &errstr):
            try:
                raise Exception((<bytes>errstr).decode())
            finally:
                free(errstr)

    def match_route(self, int method, bytes path):
        cdef cr3.match_entry* entry = cr3.match_entry_createl(path, len(path))
        cdef cr3.R3Route* route
        try:
            entry.request_method = method
            route = cr3.r3_tree_match_route(self.root, entry)
            if route:
                params = list()
                for i in range(entry.vars.slugs.size):
                    params.append((_iovec_to_bytes(&entry.vars.slugs.entries[i]),
                                   _iovec_to_bytes(&entry.vars.tokens.entries[i])))
                return <object>route.data, params
            else:
                return None, None
        finally:
            cr3.match_entry_free(entry)
