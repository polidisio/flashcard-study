import Foundation

// MARK: - Sample Decks for the App
struct SampleDecks {
    
    static func createAllDecks() -> [Deck] {
        return [
            // Historia de España
            Deck(name: "Historia de España", cards: espanaCards),
            
            // Historia Universal
            Deck(name: "Historia Universal", cards: historiaUniversalCards),
            
            // Historia de Galicia
            Deck(name: "Historia de Galicia", cards: historiaGaliciaCards),
            
            // Geografía de España
            Deck(name: "Geografía de España", cards: geografiaEspanaCards),
            
            // Geografía Universal
            Deck(name: "Geografía Universal", cards: geografiaUniversalCards),
            
            // Geografía de Galicia
            Deck(name: "Geografía de Galicia", cards: geografiaGaliciaCards),
            
            // Física
            Deck(name: "Física", cards: fisicaCards),
            
            // Química
            Deck(name: "Química", cards: quimicaCards),
            
            // Biología
            Deck(name: "Biología", cards: biologiaCards),
            
            // Matemáticas
            Deck(name: "Matemáticas", cards: matematicasCards),
            
            // Inglés
            Deck(name: "Inglés Básico", cards: inglesCards),
            
            // Gallego
            Deck(name: "Gallego", cards: gallegoCards),
            
            // Francés
            Deck(name: "Francés Básico", cards: francesCards),
            
            // Alemán
            Deck(name: "Alemán Básico", cards: alemanCards),
        ]
    }
    
    // MARK: - Historia de España
    private static var espanaCards: [Card] {
        [
            Card(front: "¿Qué son los Altamira?", back: "Cuevas con pinturas rupestres en Cantabria"),
            Card(front: "¿Qué dejaron los romanos en España?", back: "Acueductos, carreteras, ciudades, leyes, latín"),
            Card(front: "¿Cuándo se inicia la Reconquista?", back: "718 d.C. - Batalla de Covadonga"),
            Card(front: "¿Qué reino Nazarí existía en Granada?", back: "Reino nazarí de Granada (1238-1492)"),
            Card(front: "¿Quiénes fueron los Reyes Católicos?", back: "Isabel I de Castilla y Fernando II de Aragón"),
            Card(front: "¿Qué año cayó Granada?", back: "1492"),
            Card(front: "¿Qué era el Imperio Español?", back: "Monarquía hispánica con territorios en Europa, América, Asia y África"),
            Card(front: "¿Quién fue Carlos I de España?", back: "Carlos V del Sacro Imperio Romano Germánico"),
            Card(front: "¿Qué defeat sufrió España en 1588?", back: "La Armada Invencible"),
            Card(front: "¿Qué guerra tuvo lugar en España 1808-1814?", back: "Guerra de la Independencia Española"),
            Card(front: "¿Qué son las Cortes de Cádiz?", back: "Primer Parlamento constitucional español (1810)"),
            Card(front: "¿Qué es el Desastre del 98?", back: "Derrota en la Guerra Hispano-Estadounidense y pérdida de colonias"),
            Card(front: "¿Cuándo comenzó la Guerra Civil Española?", back: "18 de julio de 1936"),
            Card(front: "¿Quiénes fueron los bandos en la Guerra Civil?", back: "Republicanos vs Nacionalistas"),
            Card(front: "¿Qué fue el franquismo?", back: "Dictadura de Francisco Franco (1939-1975)"),
            Card(front: "¿Cuándo murió Franco?", back: "20 de noviembre de 1975"),
            Card(front: "¿Qué año se celebraron las primeras elecciones democráticas?", back: "1977"),
            Card(front: "¿Cuándo se aprobó la Constitución Española?", back: "1978"),
            Card(front: "¿Quién es el rey actual de España?", back: "Felipe VI (desde 2014)"),
        ]
    }
    
    // MARK: - Historia Universal
    private static var historiaUniversalCards: [Card] {
        [
            Card(front: "¿Qué es la Revolución Neolítica?", back: "Paso de cazadores a agricultores y ganaderos"),
            Card(front: "¿En qué río se fundó Roma?", back: "Río Tíber"),
            Card(front: "¿Qué civilizacion construyó las pirámides de Giza?", back: "Antiguo Egipto"),
            Card(front: "¿Quién fue el primer emperador romano?", back: "Augusto (27 a.C. - 14 d.C.)"),
            Card(front: "¿Qué persona inventó la imprenta?", back: "Johannes Gutenberg (siglo XV)"),
            Card(front: "¿Qué año cayó Constantinopla?", back: "1453"),
            Card(front: "¿Qué era el feudalismo?", back: "Sistema político y económico basado en la tierra y los señoríos"),
            Card(front: "¿En qué año llegó Colón a América?", back: "1492"),
            Card(front: "¿En qué año fue la Revolución Francesa?", back: "1789"),
            Card(front: "¿En qué año empezó la Primera Guerra Mundial?", back: "1914"),
            Card(front: "¿En qué año terminó la Segunda Guerra Mundial?", back: "1945"),
            Card(front: "¿Cuándo cayó el Muro de Berlín?", back: "9 de noviembre de 1989"),
            Card(front: "¿Qué fue el Holocausto?", back: "Genocidio de millones de judíos y otros grupos por la Alemania nazi"),
            Card(front: "¿Qué fue la Guerra Fría?", back: "Conflicto ideológico entre EUA y URSS (1947-1991)"),
        ]
    }
    
    // MARK: - Historia de Galicia
    private static var historiaGaliciaCards: [Card] {
        [
            Card(front: "¿Qué son los castros?", back: "Asentamientos fortificados de la cultura celta en Galicia"),
            Card(front: "¿Quién fue Alfonso X?", back: "Rey de Castilla que escribió las Cantigas de Santa María"),
            Card(front: "¿Qué es el Camino de Santiago?", back: "Ruta de peregrinación hacia la tumba del apóstol Santiago"),
            Card(front: "¿Qué son las 'horreos'?", back: "Graneros elevados típicos de la arquitectura gallega"),
            Card(front: "¿Qué rey incluía Galicia en su territorio?", back: "Reino de Galicia en la Edad Media"),
        ]
    }
    
    // MARK: - Geografía de España
    private static var geografiaEspanaCards: [Card] {
        [
            Card(front: "¿Cuántas comunidades autónomas tiene España?", back: "17"),
            Card(front: "¿Cuál es la comunidad más grande?", back: "Castilla y León"),
            Card(front: "¿Cuál es la comunidad más pequeña?", back: "La Rioja"),
            Card(front: "¿Qué comunidades limitan con Portugal?", back: "Galicia, Castilla y León, Extremadura, Andalucía"),
            Card(front: "¿Cuál es la capital de España?", back: "Madrid"),
            Card(front: "¿Cuál es la capital de Andalucía?", back: "Sevilla"),
            Card(front: "¿Cuál es la capital de Galicia?", back: "Santiago de Compostela"),
            Card(front: "¿Cuál es la capital de Cataluña?", back: "Barcelona"),
            Card(front: "¿Cuál es el río más largo de España?", back: "El Tajo (910 km)"),
            Card(front: "¿Cuál es la montaña más alta de España?", back: "Teide (3.718 m) en Canarias"),
            Card(front: "¿A qué tres mares/oceanos toca España?", back: "Atlántico, Cantábrico y Mediterráneo"),
        ]
    }
    
    // MARK: - Geografía Universal
    private static var geografiaUniversalCards: [Card] {
        [
            Card(front: "¿Cuántos continentes hay?", back: "5 (Europa, Asia, América, África, Oceanía) o 7 si cuentas Antártida)"),
            Card(front: "¿Cuál es el continente más grande?", back: "Asia"),
            Card(front: "¿Cuál es la capital de Francia?", back: "París"),
            Card(front: "¿Cuál es la capital de Italia?", back: "Roma"),
            Card(front: "¿Cuál es la capital de Alemania?", back: "Berlín"),
            Card(front: "¿Cuál es la capital de Reino Unido?", back: "Londres"),
            Card(front: "¿Cuál es la capital de Portugal?", back: "Lisboa"),
            Card(front: "¿Cuál es la capital de Japón?", back: "Tokio"),
            Card(front: "¿Cuál es el río más largo del mundo?", back: "Amazonas (6.400 km)"),
            Card(front: "¿Cuál es la montaña más alta del mundo?", back: "Everest (8.849 m)"),
            Card(front: "¿Cuántos océanos hay?", back: "5 (Pacífico, Atlántico, Índico, Ártico, Antártico)"),
        ]
    }
    
    // MARK: - Geografía de Galicia
    private static var geografiaGaliciaCards: [Card] {
        [
            Card(front: "¿Cuál es la capital de Galicia?", back: "Santiago de Compostela"),
            Card(front: "¿Cuántas provincias tiene Galicia?", back: "4 (A Coruña, Lugo, Ourense, Pontevedra)"),
            Card(front: "¿Qué océano toca Galicia?", back: "Océano Atlántico"),
            Card(front: "¿Cuál es la montaña más alta de Galicia?", back: "Peña Trevinca (2.127 m)"),
            Card(front: "¿Qué rías hay en Galicia?", back: "Rías Altas y Rías Baixas"),
            Card(front: "¿Qué clima tiene Galicia?", back: "Oceánico templado con muchas lluvias"),
            Card(front: "¿Qué idioma se habla en Galicia?", back: "Gallego (junto con español)"),
        ]
    }
    
    // MARK: - Física
    private static var fisicaCards: [Card] {
        [
            Card(front: "¿Qué es la física?", back: "Ciencia que estudia la materia, energía y sus interacciones"),
            Card(front: "¿Qué son las leyes de Newton?", back: "Tres leyes que describen el movimiento de los cuerpos"),
            Card(front: "¿Qué dice la 1ª ley de Newton?", back: "Ley de inercia - un cuerpo mantiene su estado si no actúa fuerza"),
            Card(front: "¿Qué dice la 2ª ley de Newton?", back: "F = m × a (fuerza = masa × aceleración)"),
            Card(front: "¿Qué dice la 3ª ley de Newton?", back: "A toda acción corresponde una reacción igual y opuesta"),
            Card(front: "¿Qué es la gravedad?", back: "Fuerza de atracción entre cuerpos con masa"),
            Card(front: "¿Qué es un átomo?", back: "Unidad básica de la materia"),
            Card(front: "¿Qué son los protones?", back: "Partículas con carga positiva en el núcleo atómico"),
            Card(front: "¿Qué son los electrones?", back: "Partículas con carga negativa alrededor del núcleo"),
            Card(front: "¿Qué es la luz?", back: "Onda electromagnética y partícula (fotón)"),
        ]
    }
    
    // MARK: - Química
    private static var quimicaCards: [Card] {
        [
            Card(front: "¿Qué es la química?", back: "Ciencia que estudia la composición y transformación de la materia"),
            Card(front: "¿Qué es un elemento químico?", back: "Sustancia pura formada por átomos del mismo tipo"),
            Card(front: "¿Qué es una molécula?", back: "Unión de dos o más átomos"),
            Card(front: "¿Qué es la Tabla Periódica?", back: "Organización de elementos por número atómico y propiedades"),
            Card(front: "¿Cuántos elementos hay?", back: "118 elementos conocidos"),
            Card(front: "¿Qué es el oxígeno?", back: "Elemento químico símbolo O, esencial para la vida"),
            Card(front: "¿Qué es el carbono?", back: "Elemento base de la vida orgánica"),
            Card(front: "¿Qué es una reacción química?", back: "Proceso donde sustancias se transforman en otras"),
            Card(front: "¿Qué son los ácidos?", back: "Sustancias que donan protones (pH < 7)"),
            Card(front: "¿Qué es el agua?", back: "H₂O - dos átomos de hidrógeno y uno de oxígeno"),
        ]
    }
    
    // MARK: - Biología
    private static var biologiaCards: [Card] {
        [
            Card(front: "¿Qué es la biología?", back: "Ciencia que estudia los seres vivos"),
            Card(front: "¿Qué es una célula?", back: "Unidad básica de todo ser vivo"),
            Card(front: "¿Qué son las células procariotas?", back: "Células sin núcleo definido (bacterias)"),
            Card(front: "¿Qué son las células eucariotas?", back: "Células con núcleo (animales, plantas, hongos)"),
            Card(front: "¿Qué es el ADN?", back: "Ácido desoxirribonucleico - portador de información genética"),
            Card(front: "¿Qué es la fotosíntesis?", back: "Proceso donde plantas convierten luz en energía"),
            Card(front: "¿Qué son las mitocondrias?", back: "Orgánulos que producen energía (ATP)"),
            Card(front: "¿Qué es la mitosis?", back: "División celular que produce dos células idénticas"),
            Card(front: "¿Qué es la evolución?", back: "Cambio de especies a lo largo del tiempo"),
            Card(front: "¿Qué es un gen?", back: "Unidad de información genética en el ADN"),
        ]
    }
    
    // MARK: - Matemáticas
    private static var matematicasCards: [Card] {
        [
            Card(front: "¿Qué es π (pi)?", back: "Relación entre perímetro y diámetro (3.14159...)"),
            Card(front: "¿Qué es el teorema de Pitágoras?", back: "a² + b² = c² en triángulos rectángulos"),
            Card(front: "¿Qué es un número primo?", back: "Número divisible solo por 1 y por sí mismo"),
            Card(front: "¿Qué es una fracción?", back: "Parte de un todo (numerador/denominador)"),
            Card(front: "¿Qué es un porcentaje?", back: "Fracción de 100 (por ciento)"),
            Card(front: "¿Qué es una ecuación?", back: "Igualdad matemática con incógnitas"),
            Card(front: "¿Qué es el área?", back: "Medida de la superficie de una figura"),
            Card(front: "¿Qué es el perímetro?", back: "Medida del contorno de una figura"),
            Card(front: "¿Qué es la media?", back: "Promedio de un conjunto de números"),
            Card(front: "¿Qué es la mediana?", back: "Valor central de un conjunto ordenado"),
        ]
    }
    
    // MARK: - Inglés
    private static var inglesCards: [Card] {
        [
            Card(front: "Hello", back: "Hola"),
            Card(front: "Goodbye", back: "Adiós"),
            Card(front: "Please", back: "Por favor"),
            Card(front: "Thank you", back: "Gracias"),
            Card(front: "Sorry", back: "Lo siento"),
            Card(front: "Yes", back: "Sí"),
            Card(front: "No", back: "No"),
            Card(front: "Good morning", back: "Buenos días"),
            Card(front: "Good night", back: "Buenas noches"),
            Card(front: "How are you?", back: "¿Cómo estás?"),
            Card(front: "I love you", back: "Te quiero"),
            Card(front: "Water", back: "Agua"),
            Card(front: "Food", back: "Comida"),
            Card(front: "House", back: "Casa"),
            Card(front: "Car", back: "Coche"),
            Card(front: "Book", back: "Libro"),
            Card(front: "Time", back: "Tiempo/Hora"),
            Card(front: "Money", back: "Dinero"),
            Card(front: "Work", back: "Trabajo"),
            Card(front: "Family", back: "Familia"),
            Card(front: "Friend", back: "Amigo"),
            Card(front: "Dog", back: "Perro"),
            Card(front: "Cat", back: "Gato"),
        ]
    }
    
    // MARK: - Gallego
    private static var gallegoCards: [Card] {
        [
            Card(front: "Ola", back: "Hola"),
            Card(front: "Adeus", back: "Adiós"),
            Card(front: "Grazas", back: "Gracias"),
            Card(front: "Por favor", back: "Por favor"),
            Card(front: "Si", back: "Sí"),
            Card(front: "Non", back: "No"),
            Card(front: "Bos días", back: "Buenos días"),
            Card(front: "Boas noites", back: "Buenas noches"),
            Card(front: "Como estás?", back: "¿Cómo estás?"),
            Card(front: "Querido", back: "Querido"),
            Card(front: "Auga", back: "Agua"),
            Card(front: "Comida", back: "Comida"),
            Card(front: "Casa", back: "Casa"),
            Card(front: "Tempo", back: "Tiempo"),
            Card(front: "Traballo", back: "Trabajo"),
            Card(front: "Familia", back: "Familia"),
            Card(front: "Can", back: "Perro"),
            Card(front: "Gato", back: "Gato"),
            Card(front: "Mar", back: "Mar"),
            Card(front: "Monte", back: "Montaña"),
        ]
    }
    
    // MARK: - Francés
    private static var francesCards: [Card] {
        [
            Card(front: "Bonjour", back: "Hola/Buenos días"),
            Card(front: "Au revoir", back: "Adiós"),
            Card(front: "Merci", back: "Gracias"),
            Card(front: "S'il vous plaît", back: "Por favor"),
            Card(front: "Oui", back: "Sí"),
            Card(front: "Non", back: "No"),
            Card(front: "Bonsoir", back: "Buenas tardes/noches"),
            Card(front: "Comment allez-vous?", back: "¿Cómo está usted?"),
            Card(front: "Je t'aime", back: "Te quiero"),
            Card(front: "L'eau", back: "El agua"),
            Card(front: "La nourriture", back: "La comida"),
            Card(front: "La maison", back: "La casa"),
            Card(front: "La voiture", back: "El coche"),
            Card(front: "Le livre", back: "El libro"),
            Card(front: "Le temps", back: "El tiempo"),
            Card(front: "L'argent", back: "El dinero"),
            Card(front: "Le travail", back: "El trabajo"),
            Card(front: "La famille", back: "La familia"),
        ]
    }
    
    // MARK: - Alemán
    private static var alemanCards: [Card] {
        [
            Card(front: "Hallo", back: "Hola"),
            Card(front: "Auf Wiedersehen", back: "Adiós"),
            Card(front: "Danke", back: "Gracias"),
            Card(front: "Bitte", back: "Por favor"),
            Card(front: "Ja", back: "Sí"),
            Card(front: "Nein", back: "No"),
            Card(front: "Guten Morgen", back: "Buenos días"),
            Card(front: "Gute Nacht", back: "Buenas noches"),
            Card(front: "Wie geht es Ihnen?", back: "¿Cómo está usted?"),
            Card(front: "Ich liebe dich", back: "Te quiero"),
            Card(front: "Das Wasser", back: "El agua"),
            Card(front: "Das Essen", back: "La comida"),
            Card(front: "Das Haus", back: "La casa"),
            Card(front: "Das Auto", back: "El coche"),
            Card(front: "Das Buch", back: "El libro"),
            Card(front: "Die Zeit", back: "El tiempo"),
            Card(front: "Das Geld", back: "El dinero"),
            Card(front: "Die Arbeit", back: "El trabajo"),
            Card(front: "Die Familie", back: "La familia"),
        ]
    }
}
