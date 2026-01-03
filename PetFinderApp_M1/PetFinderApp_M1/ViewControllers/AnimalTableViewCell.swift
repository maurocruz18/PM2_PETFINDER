import UIKit

protocol AnimalTableViewCellDelegate: AnyObject {
    func animalCellDidTapFavorite(_ cell: AnimalTableViewCell, animal: AnimalEntity)
}

class AnimalTableViewCell: UITableViewCell {
    
    weak var delegate: AnimalTableViewCellDelegate?
    private var animal: AnimalEntity?
    
    // MARK: - Elementos da UI
    
   
    private let petImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill // Preenche o quadrado sem deformar
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8 // Cantos redondos
        iv.backgroundColor = .systemGray5 // Cor de fundo enquanto carrega
        iv.image = UIImage(systemName: "pawprint.fill") // Imagem padrão
        iv.tintColor = .systemGray3
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let speciesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemBlue
        return label
    }()
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        return button
    }()
    
    // MARK: - Inicialização
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupUI() {
      
        contentView.addSubview(petImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(speciesLabel)
        contentView.addSubview(detailsLabel)
        contentView.addSubview(followButton)
        
       
        followButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            
            petImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            petImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            petImageView.widthAnchor.constraint(equalToConstant: 80),
            petImageView.heightAnchor.constraint(equalToConstant: 80),
            // Garantir que a célula tem altura mínima
            petImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 12),
            petImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            followButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            followButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            followButton.widthAnchor.constraint(equalToConstant: 44),
            followButton.heightAnchor.constraint(equalToConstant: 44),
            
        
            
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: petImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -8),
            
          
            speciesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            speciesLabel.leadingAnchor.constraint(equalTo: petImageView.trailingAnchor, constant: 12),
            speciesLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -8),
            
            
            detailsLabel.topAnchor.constraint(equalTo: speciesLabel.bottomAnchor, constant: 4),
            detailsLabel.leadingAnchor.constraint(equalTo: petImageView.trailingAnchor, constant: 12),
            detailsLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -8),
            detailsLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Ações e Configuração
    
    @objc private func favoriteTapped() {
        guard let animal = animal else { return }
        delegate?.animalCellDidTapFavorite(self, animal: animal)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        petImageView.image = UIImage(systemName: "pawprint.fill") // Reset para placeholder
        animal = nil
    }
    
    func configure(with animal: AnimalEntity) {
        self.animal = animal
        
        
        nameLabel.text = animal.name ?? "Sem nome"
        speciesLabel.text = animal.species ?? "-"
        
        var details = ""
        if let breed = animal.breed, !breed.isEmpty {
            details += "\(breed)"
        }
        if let age = animal.age, !age.isEmpty {
            details += details.isEmpty ? "" : " • "
            details += "\(age)"
        }
        detailsLabel.text = details.isEmpty ? "Sem detalhes" : details
        
        
        let heartImage = animal.isFollowing ? "heart.fill" : "heart"
        let heartColor: UIColor = animal.isFollowing ? .systemRed : .systemGray
        followButton.setImage(UIImage(systemName: heartImage), for: .normal)
        followButton.tintColor = heartColor
        
       
        
      
        if let urlString = animal.photoURLs, let url = URL(string: urlString) {
            
          
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    
                 
                    DispatchQueue.main.async {
                        
                        if self?.animal?.id == animal.id {
                            self?.petImageView.image = image
                        }
                    }
                }
            }
        }
    }
}
