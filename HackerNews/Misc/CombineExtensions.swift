
import Foundation
import Combine

extension Publisher where Output: Sequence {

    func sequence() -> AnyPublisher<Output.Element, Failure> {
        self.flatMap({ Publishers.Sequence(sequence: $0) }).eraseToAnyPublisher()
    }
}

extension Publishers {

    /// A publisher created by applying the zip function to many upstream publishers.
    struct ZipMany<P>: Publisher where P: Collection, P.Element: Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = [P.Element.Output]

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = P.Element.Failure

        public let publishers: P

        public init(_ publishers: P) {
            self.publishers = publishers
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
            let subscription = Inner(downstream: subscriber, upstream: publishers)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.ZipMany {

    struct Inner<S>: Subscription where S: Subscriber, S.Failure == Failure, S.Input == Output {

        let combineIdentifier = CombineIdentifier()

        private let cancellables: [AnyCancellable]

        init(downstream: S, upstream: P) {
            let count = upstream.count
            let outputQueues = upstream.map { _ in Queue<P.Element.Output>() }
            var completionCount = 0
            var hasCompleted = false
            let lock = NSLock()
            cancellables = upstream.enumerated().map { index, publisher in
                publisher.sink(receiveCompletion: { completion in
                    lock.lock()
                    defer {
                        lock.unlock()
                    }
                    guard case .finished = completion else {
                        downstream.receive(completion: completion)
                        hasCompleted = true
                        outputQueues.forEach { $0.removeAll() }
                        return
                    }

                    completionCount += 1

                    guard completionCount == count else {
                        return
                    }

                    downstream.receive(completion: completion)
                    hasCompleted = true
                }, receiveValue: { value in
                    lock.lock()
                    defer {
                        lock.unlock()
                    }
                    guard !hasCompleted else {
                        return
                    }
                    outputQueues[index].enqueue(value)
                    guard outputQueues.compactMap({ $0.peek() }).count == count else {
                        return
                    }
                    _ = downstream.receive(outputQueues.compactMap({ $0.dequeue() }))
                })
            }
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            cancellables.forEach { $0.cancel() }
        }
    }
}

/// A FIFO queue
fileprivate class Queue<Element> {

    private var elements: [Element] = []

    /// Adds an element to the back of the queue.
    func enqueue(_ element: Element) {
        elements.append(element)
    }

    /// Removes an element from the front of the queue.
    func dequeue() -> Element? {
        guard !elements.isEmpty else { return nil }

        return elements.removeFirst()
    }

    /// Examines the element at the head of the queue without removing it.
    func peek() -> Element? {
        elements.first
    }

    /// Removes all elements from the queue.
    func removeAll() {
        elements.removeAll()
    }
}
