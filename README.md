```
ruby httpd.rb --help
```

*Нагрузочное тестирование*
```
ab -w -c 100 -n 10000 http://127.0.0.1:8080/httptest/wikipedia_russia.html > static/ab_result.html
```
