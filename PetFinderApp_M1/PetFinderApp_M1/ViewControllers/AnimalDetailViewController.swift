import UIKit


class AnimalDetailViewController: UIViewController {
    
    // MARK: - Propriedades
    
    private let animal: AnimalEntity
    
    // MARK: - Elementos de Interface - Scroll
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - Elementos de Interface - Cabeçalho
    
 
    private let petImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .systemGray5
        iv.image = UIImage(systemName: "pawprint.fill")
        iv.tintColor = .systemGray3
        return iv
    }()
    
    private let nameLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    
    // MARK: - Elementos de Interface - Informações
    
    private let speciesLabel = UILabel()
    private let breedLabel = UILabel()
    private let genderLabel = UILabel()
    private let ageLabel = UILabel()
    private let locationLabel = UILabel()
    
    // MARK: - Elementos de Interface - Descrição
    
    private let descriptionTitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // MARK: - Elementos de Interface - Botões de Acção
    
    private let shareButton = UIButton(type: .system)
    private let contactButton = UIButton(type: .system)
    
    // MARK: - Inicialização
    
    init(animal: AnimalEntity) {
        self.animal = animal
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não foi implementado")
    }
    
    // MARK: - Ciclo de Vida
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateUI()
    }
    
    // MARK: - Configuração da Interface
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        // Configurar ScrollView e ContentView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
     
        contentView.addSubview(petImageView)
        
        // Configurar etiqueta de nome
        nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        // Configurar botão de favorito
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        contentView.addSubview(favoriteButton)
        
        // Configurar stack de informações
        let infoStackView = UIStackView()
        infoStackView.axis = .vertical
        infoStackView.spacing = 12
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        configureInfoLabel(speciesLabel)
        configureInfoLabel(breedLabel)
        configureInfoLabel(genderLabel)
        configureInfoLabel(ageLabel)
        configureInfoLabel(locationLabel)
        
        infoStackView.addArrangedSubview(speciesLabel)
        infoStackView.addArrangedSubview(breedLabel)
        infoStackView.addArrangedSubview(genderLabel)
        infoStackView.addArrangedSubview(ageLabel)
        infoStackView.addArrangedSubview(locationLabel)
        
        contentView.addSubview(infoStackView)
        
        // Configurar secção de descrição
        descriptionTitleLabel.text = "Sobre"
        descriptionTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        descriptionTitleLabel.textColor = .label
        descriptionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionTitleLabel)
        
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // Configurar botões de acção
        configureActionButton(shareButton, title: "Partilhar", color: .systemBlue, action: #selector(shareTapped))
        configureActionButton(contactButton, title: "Contactar", color: .systemGreen, action: #selector(contactTapped))
        
        contentView.addSubview(shareButton)
        contentView.addSubview(contactButton)
    }
    
    private func configureInfoLabel(_ label: UILabel) {
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureActionButton(_ button: UIButton, title: String, color: UIColor, action: Selector) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Imagem Grande (Topo) - Aumentei para 300px de altura para ver bem a foto
            petImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            petImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            petImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            petImageView.heightAnchor.constraint(equalToConstant: 300),
            
            // Nome e Favorito
            nameLabel.topAnchor.constraint(equalTo: petImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -12),
            
            favoriteButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Stack de Informações (Espécie, Raça, etc.)
            // Nota: Não conseguimos usar infoStackView diretamente aqui porque foi criada localmente no setupUI
            // Vamos usar o primeiro elemento (speciesLabel) para ancorar
            speciesLabel.superview!.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            speciesLabel.superview!.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            speciesLabel.superview!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Descrição
            descriptionTitleLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 24),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Botões
            shareButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            shareButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -6),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            
            contactButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            contactButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 6),
            contactButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contactButton.heightAnchor.constraint(equalToConstant: 50),
            contactButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actualização de Interface
    
    private func updateUI() {
        title = animal.name ?? "Detalhes"
        nameLabel.text = animal.name ?? "Sem nome"
        
        speciesLabel.text = "🐾 Espécie: \(animal.species ?? "-")"
        breedLabel.text = "🏷️ Raça: \(animal.breed ?? "-")"
        genderLabel.text = "👥 Género: \(animal.gender ?? "-")"
        ageLabel.text = "📅 Idade: \(animal.age ?? "-")"
        locationLabel.text = "📍 Localização: \(animal.location ?? "-")"
        
        descriptionLabel.text = animal.descriptionText ?? "Sem informações disponíveis"
        
        favoriteButton.isSelected = animal.isFollowing
        favoriteButton.tintColor = animal.isFollowing ? .systemRed : .systemGray
        
        // --- CARREGAMENTO DA IMAGEM ---
        if let urlString = animal.photoURLs, let url = URL(string: urlString) {
            // Download assíncrono
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.petImageView.image = image
                    }
                }
            }
        }
    }
    
    // MARK: - Acções
    
    @objc private func favoriteTapped() {
        CoreDataManager.shared.toggleFollowing(for: animal)
        updateUI()
    }
    
    @objc private func shareTapped() {
        let text = "Olha este animal que encontrei na PetFinder: \(animal.name ?? "")!"
        // Se tivermos imagem, partilhamos também a imagem
        var items: [Any] = [text]
        if let image = petImageView.image {
            items.append(image)
        }
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc private func contactTapped() {
        let alert = UIAlertController(
            title: "Contactar",
            message: "Em breve poderá contactar o abrigo diretamente.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
