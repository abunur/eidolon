import Quick
import Nimble
import ReactiveCocoa
import Kiosk
import Moya

class ArtsyProviderTests: QuickSpec {
    override func spec() {
        let fakeEndpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in
            return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)
        }

        var fakeOnlineSignal: RACSubject!
        var subject: ArtsyProvider<ArtsyAPI>!
        var defaults: NSUserDefaults!

        beforeEach {
            fakeOnlineSignal = RACSubject()
            subject = ArtsyProvider<ArtsyAPI>(endpointsClosure: fakeEndpointsClosure, stubResponses: true, onlineSignal: { fakeOnlineSignal })

            // We fake our defaults to avoid actually hitting the network
            defaults = NSUserDefaults()
            defaults.setObject(NSDate.distantFuture(), forKey: "TokenExpiry")
            defaults.setObject("Some key", forKey: "TokenKey")
        }

        it ("waits for the internet to happen before continuing with network operations") {
            var called = false

            XAppRequest(.Ping, provider: subject, defaults: defaults).subscribeNext { _ -> Void in
                called = true
            }

            expect(called) == false

            // Fake getting online
            fakeOnlineSignal.sendCompleted()

            expect(called) == true
        }
    }
}