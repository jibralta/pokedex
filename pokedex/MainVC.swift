//
//  MainVC.swift
//  pokedex
//
//  Created by Joy Umali on 11/14/16.
//  Copyright © 2016 Joy Umali. All rights reserved.
//

import UIKit
import AVFoundation

class MainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var collection: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pokemon = [Pokemon]()
    var filteredPokemon = [Pokemon]() // for searchBar function
    var musicPlayer: AVAudioPlayer!
    var inSearchMode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // this is the data source
        collection.dataSource = self
        collection.delegate = self
        searchBar.delegate = self
    
        parsePokemonCSV()
        initAudio() // music plays when loads. Pausing available when button is tapped. See below.
    }
    
    //prepping the audio
    func initAudio() {
        
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")!
        
        do {
            
            musicPlayer = try AVAudioPlayer(contentsOf: URL(string: path)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    // function to parse the csv data and put it into a form that is useful to us.
    func parsePokemonCSV() {
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")!
        
        do {
            
            let csv  = try CSV(contentsOfURL: path)
            let rows = csv.rows
            print(rows)
            
            //pull out only the pertinent data that we need from the csv.swift file.
            for row in rows {
                
                let pokeID = Int(row ["id"]!)!
                let name = row["identifier"]!
                
                let poke = Pokemon(name: name, pokedexID: pokeID)
                pokemon.append(poke)
            }
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    
    // this method sets up the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell {
            
//            creates cell, but not dynamic just yet.
//            let pokemon = Pokemon(name: "Pokemon", pokedexID: indexPath.row)    
//            cell.configureCell(pokemon)

            // makes cell dynamic and pull from array.
//            let poke = pokemon[indexPath.row]
            let poke: Pokemon!
            if inSearchMode {
                poke = filteredPokemon[indexPath.row]
                cell.configureCell(poke)
            } else {
                poke = pokemon[indexPath.row]
                cell.configureCell(poke)
            }

            return cell
        } else {
            return UICollectionViewCell()
        }
    
    }
    
    // method for when the item is selected (tapped).
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Need CODE HERE
    }
    
    // number of items in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if inSearchMode {
            
            return filteredPokemon.count
        
        }
        
        return pokemon.count
        
    }
    
    // method defines the number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    // method defines the size of the cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: 105)
    }

    @IBAction func musicButtonPressed(_ sender: UIButton) {
        
        if musicPlayer.isPlaying {
            
            musicPlayer.pause()
            sender.alpha = 0.2 // sets opacity/transparency
            
        } else {
            
            musicPlayer.play()
            sender.alpha = 1.0
        
        }
    }
    
    // anytime we hit a keystroke in the search bar, whatever is here, is going to be called.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // need new array of pokemon. 'filteredPokemon'
        
        if searchBar.text == nil || searchBar.text == "" {
            
            inSearchMode = false
            collection.reloadData() //reverts to original list of pokemon
            view.endEditing(true)
            
        } else {
            
            inSearchMode = true
        
            let lower = searchBar.text!.lowercased()
        
            //the filtered pokemon list is equal to the original list but it's filtered through the range below.
            filteredPokemon = pokemon.filter({$0.name.range(of: lower) != nil})
            collection.reloadData()
        }
        
    }

}

