


# Queue up your API requests effortlessly, ensuring they are processed one after the other.



```dart
    import 'package:api_queue_handler/api_queue_handler.dart';
```


```dart
   
   ApiManager().initialize('Your base url');

   // When we don't want to use 'await', but we want to receive the results in order.
   // For example,This will take longer, but it will be finished first.
   ApiManager().request(endpoint: 'a',runParallel:false).then((value){});
   // It will be finished second.
   ApiManager().request(endpoint: 'b',runParallel:false).then((value){});
   

```

