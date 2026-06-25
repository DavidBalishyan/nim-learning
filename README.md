# Nim Learning

Solutions to <https://adriann.github.io/programming_problems.html> implemented in [Nim](https://nim-lang.org/).

## Structure

- `elementary/` - Beginner problems (n1-n10)
- `include/` - Shared modules (e.g., `bigint.nim`)

## Running
to run the first solution, use
```sh
nim r elementary/n1_hello_world.nim
```

Or compile once and run the binary:
```sh
nim c elementary/n1_hello_world.nim
./elementary/n1_hello_world
```

### Math notation of the 11th problem
[Wikipedia Link to the Leibniz formula for $\pi$](https://en.wikipedia.org/wiki/Leibniz_formula_for_%CF%80)
$$
\sum_{k=1}^{10^6} \frac{(-1)^{k+1}}{2k-1} = 4\cdot(1-1/3+1/5-1/7+1/9-1/11\ldots).
$$