cdef extern from "r3.h":
    cdef enum:
        METHOD_GET
        METHOD_POST
        METHOD_PUT
        METHOD_DELETE
        METHOD_PATCH
        METHOD_HEAD
        METHOD_OPTIONS

    ctypedef struct r3_iovec_t:
        char* base
        unsigned int len

    ctypedef struct r3_iovec_vector_t:
        r3_iovec_t* entries
        unsigned int size

    ctypedef struct R3Node

    ctypedef struct R3Route:
        void* data

    ctypedef struct str_array:
        r3_iovec_vector_t slugs
        r3_iovec_vector_t tokens

    ctypedef struct match_entry:
        str_array vars
        int request_method

    R3Node* r3_tree_create(int cap)
    void r3_tree_free(R3Node* tree)
    R3Route* r3_tree_insert_routel(R3Node* tree, int method, const char* path, int path_len, void* data)
    int r3_tree_compile(R3Node* n, char** errstr)
    R3Route* r3_tree_match_route(const R3Node* n, match_entry* entry)
    match_entry* match_entry_createl(const char* path, int path_len)
    void match_entry_free(match_entry* entry)
