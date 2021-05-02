//
//  HeroServiceTests.swift
//  OpenDotaTests
//
//  Created by Ivan Fernando on 29/04/20.
//

import XCTest
import RxSwift
import RxBlocking
@testable import OpenDota


fileprivate class HeroAccessorMock: HeroAccessorProtocol {
    func getAllHeroStat() -> Observable<[HeroModel]> {
        let decoder = JSONDecoder()
        guard let url = Bundle(for: HeroAccessorMock.self).url(forResource: "GetAllHeroStats", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let result = try? decoder.decode([HeroModel].self, from: data)
            else {
                return Observable.empty()
            }
        
        return Observable.just(result)
    }
}

fileprivate class HeroCacheMock: HeroCacheProtocol {
    func getHero(id: Int) -> Observable<HeroModel?> {
        let decoder = JSONDecoder()
        guard let url = Bundle(for: HeroAccessorMock.self).url(forResource: "GetAllHeroStats", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let result = try? decoder.decode([HeroModel].self, from: data).first(where: { $0.id == id })
            else {
                return Observable.empty()
            }
        
        return Observable.just(result)
    }
    
    func getAllHeroStat() -> Observable<[HeroModel]> {
        let decoder = JSONDecoder()
        guard let url = Bundle(for: HeroAccessorMock.self).url(forResource: "GetAllHeroStats", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let result = try? decoder.decode([HeroModel].self, from: data)
            else {
                return Observable.empty()
            }
        
        return Observable.just(result)
    }
    
    func save(_ values: [HeroModel]) {
        
    }
}

class HeroServiceTests: XCTestCase {
    
    private var heroService: HeroServiceProtocol!
    private var heroCache: HeroCacheProtocol!
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.heroCache = HeroCacheMock()
        self.heroService = HeroService(heroAccessor: HeroAccessorMock(), heroCache: heroCache, logger: nil)
        self.disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    func testGetAllHero() throws {
        let result = self.heroService.getAllHero()
        let testCount = result.map({ $0.count })
        let testFirstId = result
            .map { (models) -> HeroModel? in
                return models.first
            }
            .map({ $0?.id })
        let testLastId = result
            .map { (models) -> HeroModel? in
                return models.last
            }
            .map({ $0?.id })
        XCTAssertEqual(try testCount.toBlocking().first(), 18)
        XCTAssertEqual(try testFirstId.toBlocking().first(), 1)
        XCTAssertEqual(try testLastId.toBlocking().first(), 89)
    }
    
    func testGetHeroById() throws {
        let testGetId = self.heroService.getHero(id: 83)
            .map({ $0?.localizedName })
        XCTAssertEqual(try testGetId.toBlocking().first(), "Treant Protector")
    }
    
    func testGetOtherHero() throws {
        let strengthNumberOfHero = 1
        let strengthRoles = Set(["Initiator", "Durable", "Disabler", "Jungler"])
        let strengthOtherHero = self.heroService
            .getOtherHero(id: 2, attribute: .strength, roles: Array(strengthRoles), resultCount: strengthNumberOfHero)
        let agilityNumberOfHero = 2
        let agilityRoles = Set(["Carry", "Escape", "Nuker"])
        let agilityOtherHero = self.heroService.getOtherHero(id: 1, attribute: .agility, roles: Array(agilityRoles), resultCount: agilityNumberOfHero)
        let intelligenceNumberOfHero = 3
        let intelligenceRoles = Set(["Nuker"])
        let intelligenceOtherHero = self.heroService.getOtherHero(id: 22, attribute: .inteligence, roles: Array(intelligenceRoles), resultCount: intelligenceNumberOfHero)
        let excludedIdHeroRole = Set(["Support", "Disabler", "Nuker", "Durable"])
        let excludedIdNumberOfHero = 3
        let excludeIdHero = self.heroService.getOtherHero(id: 3, attribute: .inteligence, roles: Array(excludedIdHeroRole), resultCount: excludedIdNumberOfHero)
        
        let testAgilityAttribute = agilityOtherHero
            .map { (models) -> [Int] in
                return models.map({ $0.id })
            }
        let testStrengthAttribute = strengthOtherHero
            .map { (models) -> [Int] in
                return models.map({ $0.id })
            }
        let testIntelligenceAttribute = intelligenceOtherHero
            .map { (models) -> [Int] in
                return models.map({ $0.id })
            }
        let testExcludedIdAttribute = excludeIdHero
            .map { (models) -> [Int] in
                return models.map({ $0.id })
            }
        let testStrengthCount = testStrengthAttribute.map({ $0.count })
        let testAgilityCount = testAgilityAttribute.map({ $0.count })
        let testIntelligenceCount = testIntelligenceAttribute.map({ $0.count })
        let testExcludedIdCount = excludeIdHero.map({ $0.count })
        let testStrengthRole = strengthOtherHero
            .map { (models) -> [Set<String>] in
                return models.map({ Set($0.roles) })
            }
        let testAgilityRole = agilityOtherHero
            .map { (models) -> [Set<String>] in
                return models.map({ Set($0.roles) })
            }
        let testIntelligenceRole = intelligenceOtherHero
            .map { (models) -> [Set<String>] in
                return models.map({ Set($0.roles) })
            }
        let testExcludedIdRole = excludeIdHero
            .map { (models) -> [Set<String>] in
                return models.map({ Set($0.roles) })
            }
        XCTAssertEqual(try testStrengthAttribute.toBlocking().first(), [83])
        XCTAssertEqual(try testAgilityAttribute.toBlocking().first(), [82, 89])
        XCTAssertEqual(try testIntelligenceAttribute.toBlocking().first(), [3, 5, 13])
        XCTAssertEqual(try testExcludedIdAttribute.toBlocking().first(), [5, 13, 17])
        XCTAssertEqual(try testStrengthCount.toBlocking().first(), strengthNumberOfHero)
        XCTAssertEqual(try testAgilityCount.toBlocking().first(), agilityNumberOfHero)
        XCTAssertEqual(try testIntelligenceCount.toBlocking().first(), intelligenceNumberOfHero)
        XCTAssertEqual(try testExcludedIdCount.toBlocking().first(), excludedIdNumberOfHero)
        XCTAssertTrue(try testStrengthRole.toBlocking().first()?.filter({ $0.intersection(strengthRoles).count > 0 }).count ?? 0 == strengthNumberOfHero)
        XCTAssertTrue(try testAgilityRole.toBlocking().first()?.filter({ $0.intersection(agilityRoles).count > 0 }).count ?? 0 == agilityNumberOfHero)
        XCTAssertTrue(try testIntelligenceRole.toBlocking().first()?.filter({ $0.intersection(intelligenceRoles).count > 0 }).count ?? 0 == intelligenceNumberOfHero)
        XCTAssertTrue(try testExcludedIdRole.toBlocking().first()?.filter({ $0.intersection(excludedIdHeroRole).count > 0 }).count ?? 0 == excludedIdNumberOfHero)
    }

}
