// Copyright (c) 2018, the gRPC project authors. Please see the AUTHORS file
// for details. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:alice/alice.dart';
import 'package:alice_grpc/alice_grpc_adapter.dart';
import 'package:grpc/grpc.dart';
import 'package:example/src/generated/helloworld.pbgrpc.dart';

/// Dart implementation of the gRPC helloworld.Greeter client.
Future<void> main(List<String> args) async {

  final Alice alice = Alice();
  final AliceGrpcAdapter aliceGrpcAdapter = AliceGrpcAdapter();
  alice.addAdapter(aliceGrpcAdapter);
  final channel = ClientChannel(
    'localhost',
    port: 50051,
    options: ChannelOptions(
      credentials: ChannelCredentials.insecure(),
      codecRegistry:
      CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
    ),
  );
  final stub = GreeterClient(channel, interceptors: [aliceGrpcAdapter]);

  final name = args.isNotEmpty ? args[0] : 'world';

  try {
    final response = await stub.sayHello(
      HelloRequest()..name = name,
      options: CallOptions(compression: const GzipCodec()),
    );
    print('Greeter client received: ${response.message}');
  } catch (e) {
    print('Caught error: $e');
  }
  await channel.shutdown();
}