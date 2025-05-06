import Foundation

enum LogFormat: String { case plain, json }

final class LocalLogger {

    static func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let line = items.map { "\($0)" }.joined(separator: separator) + terminator
        guard let data = encoder(line) else { return }
        sender(data)
    }

    private static var encoder: (_ s: String) -> Data? = { s in
        switch Config.format {
        case .plain: return s.data(using: .utf8)
        case .json : return try? JSONSerialization.data(
            withJSONObject: ["m": s], options: [])
        }
    }

    private static let sender: (_ d: Data) -> Void = { data in
        guard let url = URL(string: "http://\(Config.host):\(Config.port)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        req.httpBody = data
        URLSession.shared.dataTask(with: req).resume()
    }
}

private extension LocalLogger {
    struct Config {
        static   let host   = "127.0.0.1"
        static   let port   = 7331
        static   let format = LogFormat.json
    }
}

