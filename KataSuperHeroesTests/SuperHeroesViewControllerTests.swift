//
//  SuperHeroesViewControllerTests.swift
//  KataSuperHeroes
//
//  Created by Pedro Vicente Gomez on 13/01/16.
//  Copyright © 2016 GoKarumi. All rights reserved.
//

import Foundation
import KIF
import Nimble
import UIKit
@testable import KataSuperHeroes

class SuperHeroesViewControllerTests: AcceptanceTestCase {

    fileprivate let repository = MockSuperHeroesRepository()

    func testShowsEmptyCaseIfThereAreNoSuperHeroes() {
        givenThereAreNoSuperHeroes()

        openSuperHeroesViewController()

        tester().waitForView(withAccessibilityLabel: "¯\\_(ツ)_/¯")
    }
    
    func testShowsOneListElementIfThereIsOneHeroes() {
        let herosList = givenThereAreSomeSuperHeroes(1, avengers: false)
        
        openSuperHeroesViewController()
        
        tester().waitForView(withAccessibilityLabel: "Kata Super Heroes")
        tester().waitForView(withAccessibilityLabel: herosList[0].name)
    }
    
    func testShowsAvengersBadgeIfTheRetrievedHeroIsAnAvanger() {
        let herosList = givenThereAreSomeSuperHeroes(1, avengers: true)
        
        openSuperHeroesViewController()
        
        tester().waitForView(withAccessibilityLabel: "Kata Super Heroes")
        tester().waitForView(withAccessibilityLabel: herosList[0].name)
        let avengersAccessibilityLabels = herosList[0].name + " - Avengers Badge"
        tester().waitForView(withAccessibilityLabel: avengersAccessibilityLabels)
    }
    
    func testDoNotShowsAvengersBadgeIfTheRetrievedHeroIsNotAnAvanger() {
        let herosList = givenThereAreSomeSuperHeroes(1, avengers: false)
        
        openSuperHeroesViewController()
        
        tester().waitForView(withAccessibilityLabel: "Kata Super Heroes")
        tester().waitForView(withAccessibilityLabel: herosList[0].name)
        let avengersAccessibilityLabels = herosList[0].name + " - Avengers Badge"
        tester().waitForAbsenceOfView(withAccessibilityLabel: avengersAccessibilityLabels)
    }
    
    func testShowsTenElementsListIfThereIsTenHeroes() {
        let herosList = givenThereAreSomeSuperHeroes(10, avengers: false)
        
        openSuperHeroesViewController()
        
        tester().waitForView(withAccessibilityLabel: "Kata Super Heroes")
        
        for hero in herosList{
            tester().waitForView(withAccessibilityLabel: hero.name)
        }
    }
    
    func testShowsLoadingElementBeforeLoadingHeros(){
        givenTheSuperHeroesLoadingIsSlow()
        
        openSuperHeroesViewController()

        tester().waitForView(withAccessibilityLabel: "Tuned Loading")
    }

    func testCheckInteration(){
        let superHeroIndex = 1
        let superHeroes = givenThereAreSomeSuperHeroes()
        let superHero = superHeroes[superHeroIndex]
        openSuperHeroesViewController()
        
        tester().waitForView(withAccessibilityLabel: superHero.name)
        tester().tapRow(at: IndexPath(row: superHeroIndex, section: 0),
                        inTableViewWithAccessibilityIdentifier: "SuperHeroesTableView")
        
        tester().waitForView(withAccessibilityLabel: superHero.name)
    }
    
    func testCheckInteractionWithAllTheElement(){
        let superHeroIndex = 1
        let superHeroes = givenThereAreSomeSuperHeroes(2)
        let superHero = superHeroes[superHeroIndex]
        openSuperHeroesViewController()
        
        for (index, element) in superHeroes.enumerated() {
            tester().waitForView(withAccessibilityLabel: element.name)
            tester().tapRow(at: IndexPath(row: index, section: 0),
                            inTableViewWithAccessibilityIdentifier: "SuperHeroesTableView")
            
            tester().waitForView(withAccessibilityLabel: element.name)
            
            tester().tapView(withAccessibilityLabel: "Kata Super Heroes", traits: UIAccessibilityTraits.button)
        }
    }
    
    // TODO with spies
//    func testShowsPhotoOfOneListElementIfThereIsOneHeroes() {
//        let herosList = givenThereAreSomeSuperHeroes(1, avengers: false)
//
//        openSuperHeroesViewController()
//
//        tester().waitForView(withAccessibilityLabel: "Kata Super Heroes")
//        let cell = tester().waitForView(withAccessibilityLabel: herosList[0].name) as! SuperHeroTableViewCell
//
//
//        cell.photoImageView.image
//
//
//    }
    
    
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
    fileprivate func openSuperHeroesViewController() -> SuperHeroesViewController {
        let superHeroesViewController = ServiceLocator()
            .provideSuperHeroesViewController() as! SuperHeroesViewController
        superHeroesViewController.presenter = SuperHeroesPresenter(ui: superHeroesViewController,
                getSuperHeroes: GetSuperHeroes(repository: repository))
        let rootViewController = UINavigationController()
        rootViewController.viewControllers = [superHeroesViewController]
        present(viewController: rootViewController)
        tester().waitForAnimationsToFinish()
        return superHeroesViewController
    }
}
