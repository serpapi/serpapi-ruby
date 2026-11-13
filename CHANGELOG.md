# Changelog
 * [Unreleased] **BREAKING:** JSON responses with HTTP 200 and a top-level `error` key no longer raise `SerpApiError`. SerpApi returns searches with empty results this way (e.g. "Google hasn't returned any results for this query."), so `search`, `search_archive`, and `extract` now return them as a Hash with the message in `results[:error]`. `SerpApiError` is raised only for non-200 responses or when `search_metadata.status` is `Error`. Code that rescued `SerpApiError` to detect empty results must check `results[:error]` instead #17
 * [Unreleased] Set `SerpApiError#serpapi_error` and `#search_id` when using `symbolize_names: false`
 * [Unreleased] Add native Extract API support via the `extract` method
 * [Unreleased] Apply the `timeout` option to persistent connections
 * [Unreleased] Add Image API support
 * [Unreleased] Add Markdown search and archive output support
 * [Unreleased] Raise `SerpApiError` for non-200 text responses, including 404 responses from `get('/invalid')`
 * [2026-02-23] 1.0.3 Enhance error object #16
 * [2025-11-17] 1.0.2 Implement `inspect` functions for client #13
 * [2025-07-18] 1.0.1 Add support for old Ruby versions (2.7, 3.0)
 * [2025-07-01] 1.0.0 Full API support
