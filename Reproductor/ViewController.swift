//
//  ViewController.swift
//  Reproductor
//
//  Created by daniel on 13/03/2021.
//

import UIKit
import AVFoundation
import QuartzCore

class ViewController: UIViewController,  AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    /*
     Variables
     Son tres canciones de tipo Song,
     el array para guardarlas, el index para manejar la reproducción,
     el player y el timer para manejar el tiempo de reproducción
     */
    var song1: Song!
    var song2: Song!
    var song3: Song!
    var songs = [Song]()
    var index = 0
    var player : AVAudioPlayer!
    var timerValue: Timer!
    
    
    // Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var timer: UILabel!
    @IBOutlet weak var control: UISlider!
    @IBOutlet weak var initialText: UILabel!
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inicializamos tanto las canciones como el player
        initSongs()
        initPlayer()
        
        // Establecemos el valor máximo del slider a la duración del player
        control.maximumValue = Float(player.duration)
        
        // Variable time con la que ejecutamos la función updateSliderAndTimer cada 0,5 segundos
        timerValue = Timer.scheduledTimer(timeInterval: 0.5, target:  self, selector: #selector(updateSliderAndTimer), userInfo: nil, repeats: true)
        
        // Hacemos un círculo alrededor del botón del play
        playButton.layer.cornerRadius = playButton.frame.width/2
        playButton.backgroundColor = .white
        
    }
    
    // Función para inicializar las canciones
    func initSongs() {
        
        // Variables url con las que manejamos las rutas de las canciones en el proyecto
        let url1 = Bundle.main.url(forResource: "Tote", withExtension: "mp3")
        let url2 = Bundle.main.url(forResource: "Sharif", withExtension: "mp3")
        let url3 = Bundle.main.url(forResource: "Chojin", withExtension: "mp3")
        
        // Inicializamos las canciones pasándoles todos los parámetros
        song1 = Song(name: "Un nuevo yo despierta", artist: "El Chojin", image: #imageLiteral(resourceName: "ChojinImage"), url: url3!)
        song2 = Song(name: "Mentiras", artist: "Toteking", image: #imageLiteral(resourceName: "ToteImage"), url: url1!)
        song3 = Song(name: "Culpable", artist: "Sharif", image: #imageLiteral(resourceName: "SharifImage"), url: url2!)
        
        // Las agregamos al array de canciones
        songs.append(song1)
        songs.append(song2)
        songs.append(song3)
    }
    
    /*
     Función para inicializar el player, lo hacemos con la canción del array
     que se encuentre en la posición del index en ese momento, que inicialmente
     será la posición 0
     */
    
    func initPlayer() {
        player = try? AVAudioPlayer(contentsOf: songs[index].url)
        player.delegate = self
    }
    
    // Función para setear los valores de la canción en la interfaz
    func changeSongValues() {
        // Ocultamos el texto orientativo inicial
        initialText.isHidden = true
        // Cambiamos la imagen
        imageView.image = songs[index].image
        // Ponemos el título
        songTitle.text = songs[index].name
        // Ponemos el artista
        artistName.text = songs[index].artist
    }
    
    // Función que actualiza tanto el slider como el label del timer
    @objc func updateSliderAndTimer(){
        control.value = Float(player.currentTime)
        timer.text = getCurrentTimeAsString()
    }
    /*
     Función para parsear el currenTime de la canción como String
     con formato con minutos y segundos y devolverlo
     */
    func getCurrentTimeAsString() -> String {
        var seconds = 0
        var minutes = 0
        if let time = player?.currentTime {
            seconds = Int(time) % 60
            minutes = (Int(time) / 60) % 60
        }
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    /*
     Función para manejar el evento de que el reproductor ha terminado
     */
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Cambiamos el botón seteandolo a play
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    // Función para las filas del tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    // Función para setear la celda del tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        // Las seteamos con el nombre de la canción y su artista
        cell.textLabel?.text =  "\(songs[indexPath.row].name) -- \(songs[indexPath.row].artist)"
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 22.0)
        // Cambiamos el color de selección de la celda
        let backgroundView = UIView()
        backgroundView.backgroundColor = .blue
        cell.selectedBackgroundView = backgroundView
        return cell
        
    }
    
    // Función que se ejecutará cuando seleccionemos una de las celdas de la tabla
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Cargamos la canción que corresponda al indexPath.row en nuestro player
        player = try? AVAudioPlayer(contentsOf: songs[indexPath.row].url)
        index = indexPath.row
        changeSongValues()
        // Cambiamos el botón al pause
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        player.prepareToPlay()
        player.play()
    }
    
    
    /*
     Función para la selección auto de celda
     Lo usamos para que la selección cambie cuando cambiamos la canción
     mediante forward y backward
     */
    func autoSelectedRow(){
        // Me creo una variable indexPath en la que recojo el index de la reprodcucción y lo formateo a indexPath
        let customIndex = IndexPath(row: index, section: 0)
        // Le paso el indexPath creado por parámetro y la selección será animada
        table.selectRow(at: customIndex, animated: true, scrollPosition: UITableView.ScrollPosition.top)
    }
    
    
    // Función del botón play
    @IBAction func play(_ sender: UIButton) {
        // if para manejar el pause del reproductor
        // Si se está reproduciendo
        if player .isPlaying {
            // Lo paramos
            player.pause()
            // Cambiamos el botón seteandolo a play
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            // Si no
        } else {
            // Preparamos la reproducción
            player.prepareToPlay()
            // Llamamos al play del reproductor
            player.play()
            // Cambiamos el botón al pause
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            // Cambiamos los valores de la canción en la interfaz
            changeSongValues()
            // Llamamos a la selección auto de celda
            autoSelectedRow()
        }
    }
    // Función para el botón backWard
    @IBAction func backward(_ sender: UIButton) {
        // Manejamos que el index sea el correcto para evitar fallos a la hora de las posiciones del array
        if index > 0 && index <= 2 {
            // Restamos uno al index
            index -= 1
            // Reproducimos la canción con el nuevo index
            player = try? AVAudioPlayer(contentsOf: songs[index].url)
            // Seteamos los valores de la canción con el nuevo index
            changeSongValues()
            // Cambiamos el botón al pause
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            // Llamamos a la selección auto de celda
            autoSelectedRow()
            // Reproducimos
            player.prepareToPlay()
            player.play()
        }
    }
    
    // Función para el botón forward (Realizamos lo mismo que en backward pero a la inversa)
    @IBAction func forward(_ sender: UIButton) {
        if index >= 0 && index < 2 {
            index += 1
            player = try? AVAudioPlayer(contentsOf: songs[index].url)
            // Cambiamos el botón al pause
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            changeSongValues()
            autoSelectedRow()
            player.prepareToPlay()
            player.play()
        }
    }
    
    // Función para parar la reproducción
    @IBAction func stop(_ sender: UIButton) {
        player.stop()
        // Seteamos el tiempo de reproducción a 0 para que vaya al inicio de la canción
        player.currentTime = 0
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    
    // Función para actualizar mediante el slider la reproducción de la canción
    @IBAction func updateSongTime(_ sender: UISlider) {
        player.stop()
        player.currentTime = TimeInterval(Float(control.value))
        player.prepareToPlay()
        player.play()
    }
    
    
    
}

