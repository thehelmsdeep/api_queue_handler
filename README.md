


# Queue up your API requests effortlessly, ensuring they are processed one after the other.



```dart
    import 'package:api_queue_handler/api_queue_handler.dart';
```


```dart
   
   ApiManager().initialize('Your base url');

   final ResponseModel responseModel1 = ApiManager().request(endpoint: 'a',runParallel:false);
   final ResponseModel responseModel2 = ApiManager().request(endpoint: 'b',runParallel:false);
   final ResponseModel responseModel3 = ApiManager().request(endpoint: 'c',runParallel:false);

```

