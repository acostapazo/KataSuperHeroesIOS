//
//  SuperHeroDetailViewControllerTests.swift
//  KataSuperHeroesTests
//
//  Created by Artur Costa-Pazo on 08/05/2019.
//  Copyright © 2019 GoKarumi. All rights reserved.
//

import Foundation
import KIF
import Nimble
import UIKit
@testable import KataSuperHeroes

class SuperHeroDetailViewControllerTests: AcceptanceTestCase {
    
    fileprivate let repository = MockSuperHeroesRepository()
    
    
    func testShowsDetailViewElementsAndCheckTitle() {
        let superHero = givenThereAreSomeSuperHeroes(1)[0]
        
        openSuperHeroDetailViewController()
        
        tester().waitForView(withAccessibilityLabel: superHero.name)
    }
    
    func testShowsDetailViewElementsWhenValidSuperHero() {
        let superHero = givenThereAreSomeSuperHeroes(1)[0]
        
        openSuperHeroDetailViewController()
        
        tester().waitForView(withAccessibilityLabel: "Name: \(superHero.name)")
        tester().waitForView(withAccessibilityLabel: "Description: \(superHero.name)")
        tester().waitForView(withAccessibilityLabel: "Photo: \(superHero.name)")
    }

    func testShowsDetailViewElementsWhenValidSuperHeroAndAvangersIsTrue() {
        let superHero = givenThereAreSomeSuperHeroes(1, avengers: true)[0]
        
        openSuperHeroDetailViewController()
        
        tester().waitForView(withAccessibilityLabel: "Name: \(superHero.name)")
        tester().waitForView(withAccessibilityLabel: "Description: \(superHero.name)")
        tester().waitForView(withAccessibilityLabel: "Avengers Badge")
        tester().waitForView(withAccessibilityLabel: "Photo: \(superHero.name)")
    }
    
    func testShowsLoadingElementBeforeLoadingHeros(){
        givenTheSuperHeroesLoadingIsSlow()
        
        openSuperHeroDetailViewController()
        
        tester().waitForView(withAccessibilityLabel: "Tuned Loading")
    }

    
    fileprivate func givenTheSuperHeroesLoadingIsSlow() {
        repository.superHeroes = nil
    }
    
    fileprivate func givenThereAreNoSuperHeroes() {
        _ = givenThereAreSomeSuperHeroes(0)
    }
    
    fileprivate func givenThereAreSomeSuperHeroes(_ numberOfSuperHeroes: Int = 10,
                                                  avengers: Bool = false) -> [SuperHero] {
        var superHeroes = [SuperHero]()
        for i in 0..<numberOfSuperHeroes {
            let superHero = SuperHero(name: "SuperHero - \(i)",
                photo: NSURL(string: "https://i.annihil.us/u/prod/marvel/i/mg/c/60/55b6a28ef24fa.jpg") as URL?,
                isAvenger: avengers, description: "Description - \(i)")
            superHeroes.append(superHero)
        }
        repository.superHeroes = superHeroes
        return superHeroes
    }
    
    @discardableResult
    fileprivate func openSuperHeroDetailViewController() -> SuperHeroDetailViewController {
        let superHeroName = "SuperHero - 0"
        
        let superHeroDetailViewController = ServiceLocator()
            .provideSuperHeroDetailViewController(superHeroName) as! SuperHeroDetailViewController
        superHeroDetailViewController.presenter = SuperHeroDetailPresenter(ui: superHeroDetailViewController,
                                                                           superHeroName: superHeroName,
                                                                           getSuperHeroByName: GetSuperHeroByName(repository: repository))
        
        let rootViewController = UINavigationController()
        rootViewController.viewControllers = [superHeroDetailViewController]
        present(viewController: rootViewController)
        tester().waitForAnimationsToFinish()
        return superHeroDetailViewController
    }
}
