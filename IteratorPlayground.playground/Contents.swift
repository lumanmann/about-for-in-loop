import UIKit

// MARK:- 實現一個 Sequence
struct FirstLetterIterator: IteratorProtocol {
    let strings: [String]
    var offset: Int
    
    init(strings: [String]) {
        self.strings = strings
        offset = 0
    }
    
    mutating func next() -> String? {
        guard offset < strings.endIndex else { return nil }
        let string = strings[offset]
        offset += 1
        return String(string.first!)
    }
}


struct FirstLetterSequence: Sequence {
    let strings: [String]
    
    func makeIterator() -> FirstLetterIterator {
        return FirstLetterIterator(strings: strings)
    }
}

for letter in FirstLetterSequence(strings: ["apple","banana","car"]){
    print(letter)
}


// https://developer.apple.com/documentation/swift/iteratorprotocol
struct CountdownIterator: IteratorProtocol {
    let countdown: Countdown
    var times = 0
    
    init(_ countdown: Countdown) {
        self.countdown = countdown
    }
    
    mutating func next() -> Int? {
        let nextNumber = countdown.start - times
        guard nextNumber > 0
            else { return nil }
        
        times += 1
        return nextNumber
    }
}

struct Countdown: Sequence {
    let start: Int
    
    func makeIterator() -> CountdownIterator {
        return CountdownIterator(self)
    }
}

let threeTwoOne = Countdown(start: 3)
for count in threeTwoOne {
    print("\(count)...")
}



// MARK:- 實現一個 Queue (書中範例)
// 先進先出
public struct Queue<T> {
    private var array: [T?] = []
    private var head = 0
    
    public var isEmpty: Bool {
        return count == 0
    }
    
    public var count: Int {
        return array.count - head
    }
    
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    public mutating func dequeue() -> T? {
        guard head < array.count,
            let element = array[head] else {
                return nil
        }
        
        // soft delete 空間還保留著
        array[head] = nil
        head += 1
        
        // array 長度大於50及空的多於25% 才去真的 delete 那個位置
        let percentage = Double(head) / Double(array.count)
        if array.count > 50,
            percentage > 0.25 {
            array.removeFirst(head)
            head = 0
        }
        return element
    }
}


// 試用一下
struct Moviee {
    var title: String
    var rating: RatingType
    
    enum RatingType: Int {
        case bad = 0
        case medium
        case good
    }
    
    init(title: String, rating: RatingType) {
        self.title = title
        self.rating = rating
    }
}

var queue = Queue<Moviee>()
queue.enqueue( Moviee(title: "Lala Land", rating: .good))
queue.enqueue( Moviee(title: "Ant man", rating: .medium))
queue.enqueue( Moviee(title: "Joker", rating: .good))
queue.enqueue( Moviee(title: "??", rating: .bad))
queue.dequeue() // Lala Land 被刪掉

//for movie in queue {
//    print(movie?.title ?? "No title")
//}

extension Queue: Sequence {
    public func makeIterator() -> IndexingIterator<ArraySlice<T?>> {
        let nonEmptyValues = array[head ..< array.count]
        return nonEmptyValues.makeIterator() // 用 array 本身的 iterator
    }
}

print("--- Queue ---")
for movie in queue {
    print(movie?.title ?? "No title")
}


let sortedTickets = queue.sorted { $0!.rating.rawValue > $1!.rating.rawValue }

print("\n")
print("--- Queue 排序後 ---")
for movie in sortedTickets {
    print(movie?.title ?? "No Description")
}

// 成功使用 for in loop, sort ✅


// MARK:- 實現一個 Linked List + Stack
enum List<Element> {
    case end
    indirect case node(Element, next: List<Element>)
}

// indirect 提示編譯器不要直接在值類型中直接 nesting
// https://swifter.tips/indirect-nested-enum/
// https://appventure.me/guides/advanced_practical_enum_examples/introduction.html

extension List {
    
    func add(_ x: Element) -> List {
        return .node(x, next: self) // 把自己設定成 new value 的 next = 把 new value 加在前面
    }
}
// nodes 會長這樣: 3 -> 2 -> 1
let list = List<Int>.end.add(1).add(2).add(3)

// extension List: ExpressibleByArrayLiteral {
//    public init(arrayLiteral elements: Element...) {
//        self = elements.reversed().reduce(.end) { partialList, element in
//            partialList.add(element)
//        }
//    }
// }
// let list2: List = [3,2,1]


extension List {
    mutating func push(_ x: Element) {
        self = self.add(x)
        
    }
    mutating func pop() -> Element? {
        switch self {
        case .end: return nil
        case let .node(x, next: tail):
            self = tail
            return x
        }
    }
    
}

// 先進後出, 後進先出
var stack: List<Int> = List<Int>.end.add(1).add(2).add(3)


stack.push(4)
stack
stack.pop()
stack

// 不能用
// for s in stack {
//    print(s)
// }

// conform IteratorProtocol + Sequence Protocol
extension List: IteratorProtocol, Sequence {
    mutating func next() -> Element? {
        return pop()
    }
}


// 可以用啦~
print("\n")
for s in stack {
    print(s)
}

let stackArray = stack.map { $0 * 2 }

print("\n")
for s in stackArray {
    print(s)
}


// MARK: Extra

protocol Movie {
    var id: Int { get }
    var name: String { get }
    var gerne: String { get }
    var rating: Int { get }
    var duration: TimeInterval { get }
}

protocol Selected {
    var date: Date { get }
    var selectedBy: String { get }
    var movie: Movie { get }
}


struct MovieItem: Movie {
    var id: Int
    var name: String
    var gerne: String
    var rating: Int
    var duration: TimeInterval
}

struct SelectedMovie: Selected {
    var date: Date
    var selectedBy: String
    var movie: Movie
}

// LinkedList Node
class LinkedList<T> {
    let head: T
    var nextItem: LinkedList<T>?
    
    init(_ item: T) {
        self.head = item
    }
}

class MoviesFactory {
    static func getMoviesArray() -> [Movie] {
        return [
            MovieItem(id: 0, name: "Aquaman", gerne: "action", rating: 4, duration: 7200),
            MovieItem(id: 1, name: "Joker", gerne: "action", rating: 5, duration: 7200),
            MovieItem(id: 2, name: "La La Land", gerne: "romance", rating: 3, duration: 7200),
            MovieItem(id: 3, name: "Superman", gerne: "action", rating: 2, duration: 3600),
            MovieItem(id: 4, name: "Antman", gerne: "action", rating: 1, duration: 7200),
        ]
    }
    
    static func getSelectedMovies() -> [Selected] {
        return [
            SelectedMovie(date: Date(), selectedBy: "Natalie", movie: MovieItem(id: 0, name: "Aquaman", gerne: "action", rating: 4, duration: 7200)),
            SelectedMovie(date: Date(timeIntervalSinceNow: -2000), selectedBy: "John", movie: MovieItem(id: 1, name: "Joker", gerne: "action", rating: 5, duration: 7200)),
            SelectedMovie(date: Date(timeIntervalSinceNow: -4444), selectedBy: "Natalie", movie: MovieItem(id: 2, name: "La La Land", gerne: "romance", rating: 3, duration: 7200))
        ]
    }
    
    static func getMoviesList() -> LinkedList<Movie> {
        let head = LinkedList<Movie>(MovieItem(id: 0, name: "Aquaman", gerne: "action", rating: 4, duration: 7200))
        head.nextItem = LinkedList<Movie>(MovieItem(id: 1, name: "Joker", gerne: "action", rating: 5, duration: 7200))
        head.nextItem?.nextItem = LinkedList<Movie>(MovieItem(id: 2, name: "La La Land", gerne: "romance", rating: 3, duration: 7200))
        head.nextItem?.nextItem?.nextItem = LinkedList<Movie>(MovieItem(id: 3, name: "Superman", gerne: "action", rating: 2, duration: 3600))
        head.nextItem?.nextItem?.nextItem?.nextItem = LinkedList<Movie>(MovieItem(id: 4, name: "Antman", gerne: "action", rating: 1, duration: 7200))
        return head
    }
    
    static func getMoviesDictionary() -> [String : Movie] {
        return [
            "1" : MovieItem(id: 0, name: "Aquaman", gerne: "action", rating: 4, duration: 7200),
            "2" :  MovieItem(id: 4, name: "Antman", gerne: "action", rating: 1, duration: 7200)
        ]
    }
}

// 定義4種對應的 Iterator
protocol MovieIterator {
    func next() -> Movie?
}

class LinkedListMovieIterator: MovieIterator {
    private var cursor: LinkedList<Movie>?
    private let items: LinkedList<Movie>
    
    init(_ items: LinkedList<Movie>) {
        self.items = items
        self.cursor = self.items
    }
    
    func next() -> Movie? {
        let movie = self.cursor?.head
        self.cursor = self.cursor?.nextItem
        return movie
    }
}

class ArrayMovieIterator: MovieIterator {
    private var cursor: Int?
    private let items: [Movie]
    
    init(_ items: [Movie]) {
        self.items = items
    }
    
    func next() -> Movie? {
        if let idx = getNextCursor(cursor) {
            self.cursor = idx
            return self.items[idx]
        }
        return nil
    }
    
    private func getNextCursor(_ cursor: Int?) -> Int? {
        if var idx = cursor, idx < items.count - 1 {
            idx += 1
            return idx
        } else if cursor == nil, items.count > 0 {
            return 0
        } else {
            return nil
        }
    }
}

class DictionaryMovieIterator: ArrayMovieIterator {
    init(_ items: [String: Movie]) {
        let items: [Movie] = Array(items.values)
        super.init(items)
    }
}

class SelectedMovieIterator: ArrayMovieIterator {
    init(_ items: [Selected]) {
        let items: [Movie] = items.map { $0.movie }
        super.init(items)
    }
}

// MARK: Conform Iterable （類似 Sequence 的一個 protocol）
protocol Iterable {
    func makeIterator() -> MovieIterator
}

class MovieQueue: Iterable {
    private let queue: LinkedList<Movie>
    init(_ queue: LinkedList<Movie>) {
        self.queue = queue
    }
    
    func makeIterator() -> MovieIterator {
        return LinkedListMovieIterator(queue)
    }
}

class SelectedMovies: Iterable {
    private let items: [Selected]
    init(_ items: [Selected]) {
        self.items = items
    }
    
    
    func makeIterator() -> MovieIterator {
        return SelectedMovieIterator(items)
    }
}

class ArrayMovie: Iterable {
    private let movies: [Movie]
    init(_ movies: [Movie]) {
        self.movies = movies
    }
    
    
    func makeIterator() -> MovieIterator {
        return ArrayMovieIterator(movies)
    }
    
    func filter(_ isIncluded: (Movie) -> Bool) -> [Movie] {
        var result: [Movie] = []
        let iterator = makeIterator()
        while let item = iterator.next() {
            if isIncluded(item) {
                result.append(item)
            }
        }
        
        return result
    }
}

class DictionaryMovie: Iterable {
    private let movies: [String : Movie]
    init(_ movies: [String : Movie]) {
        self.movies = movies
    }
    
    func makeIterator() -> MovieIterator {
        return DictionaryMovieIterator(movies)
    }
}


func printMovies(iterator: MovieIterator) {
    while let item = iterator.next() {
        print(item.name)
    }
}



var queueMovie = MovieQueue(MoviesFactory.getMoviesList())
var selected = SelectedMovies(MoviesFactory.getSelectedMovies())
var array = ArrayMovie(MoviesFactory.getMoviesArray())
var dictionary = DictionaryMovie(MoviesFactory.getMoviesDictionary())

func printMoviesInventory() {
    print("==========Queue============")
    printMovies(iterator: queueMovie.makeIterator())
    print("==========Array==========")
    printMovies(iterator: array.makeIterator())
    print("==========Selected==========")
    printMovies(iterator: selected.makeIterator())
    print("==========Dictionary===========")
    printMovies(iterator: dictionary.makeIterator())
}


printMoviesInventory()


let goodMovies = array.filter{ $0.rating > 4 }
goodMovies
