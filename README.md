# splintr

Natural cubic splines with interpretable intercepts: 'centres' a basis generated using `splines::ns()` on a specified x-value. When used in a model formula, this allows the model intercept to be interpreted with respect to that central x-value, rather than with respect to the x-value of the first `ns()` knot.

```
Sys.setenv(GITHUB_PAT = "")
install_github("simisc/splintr", auth_token = github_pat())
```
