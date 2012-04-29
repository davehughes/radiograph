import json
import re

'''
  Functions and codecs for converting JSON keys between camelCase and
  underscore_case so Python and Javascript code can both look conventional.
'''
def camel2underscore(name):
    ''' Convert camelCase strings to underscore_case '''
    replace = lambda m: '%s_%s' % (m.group()[0], m.group()[1].lower())
    return re.sub(r"[a-z][A-Z]", replace, name)

def underscore2camel(name):
    ''' Convert underscore_case strings to camelCase '''
    replace = lambda m: m.group()[0] + m.group()[2].upper()
    return re.sub(r"[a-z]_[a-z]", replace, name)

def camelize(data):
    ''' Recursively convert underscore_case dict keys into camelCase ones '''
    if isinstance(data, dict):
        return {underscore2camel(k): camelize(v) for k, v in data.items()}
    elif isinstance(data, (list, tuple)):
        return [camelize(x) for x in data]
    return data     

def underscorize(data):
    ''' Recursively convert camelCase dict keys into underscore_case ones '''
    if isinstance(data, dict):
        return {camel2underscore(k): underscorize(v) for k, v in data.items()}
    elif isinstance(data, (list, tuple)):
        return [underscorize(x) for x in data]
    return data     

class CamelizingJSONEncoder(json.JSONEncoder):
    ''' Encoder that first runs camelize on its data '''
    def encode(self, data, *args, **kwargs):
        data = camelize(data)
        return super(CamelizingJSONEncoder, self).encode(data, *args, **kwargs)

class UnderscorizingJSONDecoder(json.JSONDecoder):
    ''' Decoder that first runs underscorize on its data '''
    def decode(self, data, *args, **kwargs):
        result = (super(UnderscorizingJSONDecoder, self)
                  .decode(data, *args, **kwargs))
        return underscorize(data)
