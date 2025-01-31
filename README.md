# XnKV
> this library is part of [xn](https://github.com/ivanmoskalev/xn) suite

Minimalistic, thread-safe and fast key-value store for iOS / macOS. It utilizes the brilliant LMDB library under the hood. Public domain license.

> [!NOTE]
> It's known that LMDB doesn't work out of the box in macOS Sandbox due to mutex restrictions. This library accounts for that, disabling in-built LMDB locking, instead utilizing Swift actor model to provide synchronization.

## Installation

> [!WARNING]
> This is still work-in-progress. Distribution instructions will be included once the work is done.

## Contributing

Please note that contributions are accepted if they align with the vision for the library. Please open an issue first to discuss proposed changes. 

## License

Since this library vendors LMDB source code, it has two licenses applicable to it.

- `XnKV` Swift code: This project (and the rest of the xn suite) is released into the public domain under [The Unlicense](https://unlicense.org/). Do whatever you want with it however you want.
- `LMDB` (`Sources/liblmdb`): Bundled under the OpenLDAP Public License 2.8.
