## Performance Comparison

### Ruby 4.0.0 vs 3.4.4 vs Ruby 2.7.8 Performance

| Metric | Ruby 2.7.8 | Ruby 3.4.4 | Ruby 4.0.0 | Improvement (3.4.4 vs 2.7.8) | Improvement (4.0.0 vs 3.4.4) |
|--------|------------|------------|------------|------------------------------|------------------------------|
| **SerpApi Non-Persistent** | 100.93 req/s | 114.97 req/s | 120.09 req/s | **+13.9%** | **+4.5%** |
| **SerpApi Persistent** | 226.82 req/s | 255.07 req/s | 296.05 req/s | **+12.4%** | **+16.1%** |
| **HTTP.rb Non-Persistent** | 270.62 req/s | 294.01 req/s | 319.81 req/s | **+8.6%** | **+8.8%** |
| **HTTP.rb Persistent** | 347.04 req/s | 570.95 req/s | 456.93 req/s | **+64.5%** | **-20.0%** |

#### Thread Pool Demo

Here's a benchmark of `demo/demo_thread_pool.rb`:

** Benchmark Ruby 3.4.8 vs Ruby 4.0.0 **

benchmark: (demo/demo_thread_pool.rb)

| ruby | runtime (s) | thread | time/thread (s) |
|------|------------:|-------:|----------------:|
| 3.4.8 | 0.018644 | 4 | 0.004661 |
| 4.0.0 | 0.017302 | 4 | 0.004326 |

Ruby 4.0.0 shows a slight improvement over Ruby 3.4.8, but the difference is not significant using thread.
Ractor could be considered for a more efficient use of resources but it's still in the experimental stage.

Note: in this benchmark, `thread == HTTP connections`.

### Key Takeaways

1. **Upgrade to Ruby 3.4.4**: Clear performance benefits across all scenarios
2. **Use Persistent Connections**: 2x+ performance improvement in most cases
3. **HTTP.rb Performance**: Particularly benefits from Ruby 3.4.4 with persistent connections
4. **SerpApi Optimization**: Shows consistent ~2.2x improvement with persistent connections regardless of Ruby version
5. **Ruby 4.0.0 Performance**: Shows mixed results with some regressions compared to 3.4.4, particularly for HTTP.rb persistent connections. Ruby 4.0.0 was just released for Christmas 2025, and HTTP.rb has not been optimized for it yet.

The older library (google-search-results-ruby) was performing at 55 req/s on Ruby 2.7.8, which is 2x slower than the current version (serpapi-ruby) on Ruby 3.4.4 or 4.0.0. 

**Context** This benchmark was performed on warmup search results using a MacBook Pro 2025 connected via Wi-Fi 6.0 home network on AT&T fiber from Austin, TX (no network optimization).
