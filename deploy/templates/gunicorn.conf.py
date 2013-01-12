import multiprocessing

bind = '{{ api.server.location }}'
workers = multiprocessing.cpu_count() * 2 + 1
