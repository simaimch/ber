# Ber

## Modding:

Value Provided by Mod -> Previous Value


### ?AnyValue -> AnyValue
    Ignores the modded value if the original values does not exist.

    Example
    Base:{
    }
    Mod:{
        "!+example": ",Something New"
    }
    Result:{
    }

### !AnyValue -> AnyValue
    Ignores the modded value if the original values existe. Can't be combined with ?

    Example
    Base:{
        "example":{
            "s1":"string1",
            "s2":"string2"
        }
    }
    Mod:{
        "example":{
            "s2":"string3",
            "s3":"string4"
        }
    }
    Result:{
        "example":{
            "s1":"string1",
            "s2":"string2"
        }
    }

### -True -> AnyValue
    Deletes the original value if it exists. Can't be combined with other directives

    Example
    Base:{
        "example": "Example String"
    }
    Mod:{
        "-example": true
    }
    Result:{
    }


### AnyValue -> Null
    Example
    Base:{
    }
    Mod:{
        "example": "NewString"
    }
    Result:{
        "example": "NewString"
    }

### §AnyValue -> AnyValue
    Will replace the original value. If the original value does not exist works like AnyValue -> Null
    Example
    Base:{
        "example": [1,3,5]
    }
    Mod:{
        "§example": [2,4,6]
    }
    Result:{
        "example": [2,4,6]
    }

### String -> String
§String-> String
Int -> Int
§Int -> Int
Float -> Float
$Float -> Float
Bool -> Bool
§Bool -> Bool
    The original value gets replaced

    Example
    Base:{
        "example": "String"
    }
    Mod:{
        "example": "NewString"
    }
    Result:{
        "example": "NewString"
    }

### +String -> String
    Append a string.

    Example
    Base:{
        "example": "String"
    }
    Mod:{
        "+example": ",Something New"
    }
    Result:{
        "example": "String,Something New"
    }

### *String -> String
    Prepends a string

    Example
    Base:{
        "example": "String"
    }
    Mod:{
        "*example": ",Something New"
    }
    Result:{
        "example": ",Something NewString"
    }

### Array->Array
+Array->Array
    Modded values will be appended to the base values.

    Example
    Base:{
        "example": [1,3,5]
    }
    Mod:{
        "example": [2,4,6]
    }
    Result:{
        "example": [1,3,5,2,4,6]
    }

### *Array->Array
    Modded values will be prepended to the base values.

    Example
    Base:{
        "example": [1,3,5]
    }
    Mod:{
        "example": [2,4,6]
    }
    Result:{
        "example": [2,4,6,1,3,5]
    }


### Object -> Object
    All entries will be handled recursively by the same rules the base objects get handeld by.

    Example
    Base:{
        "example": {
            "Value1": "v1",
            "Value3": "v3"
        }
    }
    Mod:{
        "example": {
            "Value1": "overriden",
            "Value2": "v2",
        }
    }
    Result:{
        "example": {
            "Value1": "overriden",
            "Value2": "v2",
            "Value2": "v3"
        }
    }