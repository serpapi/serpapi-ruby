# Changelog
 * [2026-06-03] 1.1.0 Fix `timeout` being ignored in persistent (default) mode; honor a constructor-level `symbolize_names`; stop mutating the caller's options hash; add `raise_on_search_error` so `search_archive` can return archived errors instead of raising (#17); reduce per-request hash allocations; allow HTTP.rb 6.x; add an offline (key-free) test suite and multi-version CI.
 * [2026-02-23] 1.0.3 Enhance error object #16
 * [2025-11-17] 1.0.2 Implement `inspect` functions for client #13
 * [2025-07-18] 1.0.1 Add support for old Ruby versions (2.7, 3.0)
 * [2025-07-01] 1.0.0 Full API support
