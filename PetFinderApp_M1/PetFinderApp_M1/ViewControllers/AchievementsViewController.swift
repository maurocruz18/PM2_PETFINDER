import UIKit

/// Controlador que apresenta as conquistas do utilizador
/// Exibe conquistas desbloqueadas e bloqueadas num formato de grelha
class AchievementsViewController: UIViewController {
    
    // MARK: - Propriedades de Interface
    
    /// Vista de coleção para exibir conquistas em grelha
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        // Calcular tamanho dos itens (2 por linha)
        let itemWidth = (UIScreen.main.bounds.width - 16 * 3) / 2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    /// Etiqueta mostrada quando não há conquistas
    private let emptyLabel = UILabel()
    
    /// Etiqueta de estatísticas do utilizador
    private let statsLabel = UILabel()
    
    /// Vista contentor para estatísticas
    private let statsContainerView = UIView()
    
    // MARK: - Propriedades de Dados
    
    /// Lista de todas as conquistas (obtida dinamicamente do AchievementManager)
    private var achievements: [Achievement] = []
    
    // MARK: - Ciclo de Vida
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStatsView()
        setupCollectionView()
        setupConstraints()
        loadAchievements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Recarregar conquistas sempre que a vista aparecer
        loadAchievements()
    }
    
    // MARK: - Configuração da Interface
    
    /// Configura os elementos básicos da interface
    private func setupUI() {
        title = "Conquistas"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Botão de reset (apenas para desenvolvimento)
        #if DEBUG
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.counterclockwise"),
            style: .plain,
            target: self,
            action: #selector(resetAchievements)
        )
        #endif
        
        // Configurar etiqueta de estado vazio
        emptyLabel.text = "Desbloqueie conquistas\nseguindo animais!"
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
    }
    
    /// Configura a vista de estatísticas no topo
    private func setupStatsView() {
        statsContainerView.translatesAutoresizingMaskIntoConstraints = false
        statsContainerView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        statsContainerView.layer.cornerRadius = 12
        
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        statsLabel.numberOfLines = 0
        statsLabel.textAlignment = .center
        statsLabel.font = .systemFont(ofSize: 14, weight: .medium)
        
        statsContainerView.addSubview(statsLabel)
        view.addSubview(statsContainerView)
        
        NSLayoutConstraint.activate([
            statsLabel.topAnchor.constraint(equalTo: statsContainerView.topAnchor, constant: 12),
            statsLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 12),
            statsLabel.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -12),
            statsLabel.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: -12)
        ])
    }
    
    /// Configura a vista de coleção
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(AchievementCell.self, forCellWithReuseIdentifier: "AchievementCell")
        
        view.addSubview(collectionView)
    }
    
    /// Configura as restrições de layout
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Vista de estatísticas no topo
            statsContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            statsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Vista de coleção abaixo das estatísticas
            collectionView.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Etiqueta vazia centrada
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Gestão de Dados
    
    /// Carrega as conquistas do AchievementManager
    private func loadAchievements() {
        achievements = AchievementManager.shared.getAllAchievements()
        updateStatsLabel()
        collectionView.reloadData()
    }
    
    /// Atualiza a etiqueta de estatísticas
    private func updateStatsLabel() {
        let stats = AchievementManager.shared.getUserStats()
        let unlockedCount = achievements.filter { $0.isUnlocked }.count
        
        let statsText = """
        📊 Progresso: \(unlockedCount)/\(achievements.count) conquistas
        ❤️ Animais seguidos: \(stats.followingCount)
        👁️ Visitas à app: \(stats.visitCount)
        """
        
        statsLabel.text = statsText
    }
    
    // MARK: - Acções
    
    /// Reset de conquistas (apenas para desenvolvimento)
    @objc private func resetAchievements() {
        let alert = UIAlertController(
            title: "Reset de Conquistas",
            message: "Tem certeza que deseja resetar todas as conquistas? (Apenas para testes)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            AchievementManager.shared.resetAllAchievements()
            self.loadAchievements()
            
            let successAlert = UIAlertController(
                title: "Reset Completo",
                message: "Todas as conquistas foram resetadas.",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(successAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - Data Source da Vista de Coleção

extension AchievementsViewController: UICollectionViewDataSource {
    
    /// Número de conquistas a exibir
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return achievements.count
    }
    
    /// Configura cada célula com dados de uma conquista
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AchievementCell", for: indexPath) as! AchievementCell
        let achievement = achievements[indexPath.row]
        
        // Obter progresso da conquista
        if let achievementType = AchievementManager.AchievementType(rawValue: achievement.id) {
            let progress = AchievementManager.shared.getProgress(for: achievementType)
            cell.configure(with: achievement, progress: progress)
        } else {
            cell.configure(with: achievement, progress: 0)
        }
        
        return cell
    }
}

// MARK: - Delegate da Vista de Coleção

extension AchievementsViewController: UICollectionViewDelegate {
    
    /// Mostra detalhes quando uma conquista é selecionada
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let achievement = achievements[indexPath.row]
        showAchievementDetails(achievement)
    }
    
    /// Apresenta um alerta com detalhes da conquista
    /// - Parameter achievement: Conquista a exibir
    private func showAchievementDetails(_ achievement: Achievement) {
        var message = achievement.description
        
        // Adicionar progresso se a conquista não estiver desbloqueada
        if !achievement.isUnlocked, let achievementType = AchievementManager.AchievementType(rawValue: achievement.id) {
            let progress = AchievementManager.shared.getProgress(for: achievementType)
            message += "\n\nProgresso: \(Int(progress))%"
        }
        
        let alert = UIAlertController(
            title: achievement.isUnlocked ? "✅ \(achievement.title)" : "🔒 \(achievement.title)",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        present(alert, animated: true)
    }
}

// MARK: - Célula de Conquista

/// Célula personalizada para exibir uma conquista
class AchievementCell: UICollectionViewCell {
    
    // MARK: - Elementos de Interface
    
    /// Vista contentor com fundo
    private let containerView = UIView()
    
    /// Ícone da conquista
    private let iconView = UIImageView()
    
    /// Título da conquista
    private let titleLabel = UILabel()
    
    /// Descrição da conquista
    private let descriptionLabel = UILabel()
    
    /// Ícone de cadeado para conquistas bloqueadas
    private let lockImageView = UIImageView()
    
    /// Barra de progresso
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    /// Etiqueta de percentagem de progresso
    private let progressLabel = UILabel()
    
    // MARK: - Inicialização
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não foi implementado")
    }
    
    // MARK: - Configuração da Interface
    
    /// Configura todos os elementos visuais da célula
    private func setupUI() {
        // Vista contentor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.clear.cgColor
        
        // Ícone da conquista
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Título
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Descrição
        descriptionLabel.font = .systemFont(ofSize: 11, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Ícone de cadeado
        lockImageView.image = UIImage(systemName: "lock.fill")
        lockImageView.tintColor = .systemGray
        lockImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Barra de progresso
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .systemGray5
        
        // Etiqueta de progresso
        progressLabel.font = .systemFont(ofSize: 10, weight: .medium)
        progressLabel.textColor = .secondaryLabel
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Adicionar elementos
        containerView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(lockImageView)
        containerView.addSubview(progressView)
        containerView.addSubview(progressLabel)
        contentView.addSubview(containerView)
        
        // Restrições de layout
        NSLayoutConstraint.activate([
            // Vista contentor preenche toda a célula
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Ícone no topo, centrado
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 50),
            iconView.heightAnchor.constraint(equalToConstant: 50),
            
            // Título abaixo do ícone
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            // Descrição abaixo do título
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            // Barra de progresso
            progressView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            // Etiqueta de progresso
            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 4),
            progressLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            progressLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            // Cadeado no canto superior direito
            lockImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            lockImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            lockImageView.widthAnchor.constraint(equalToConstant: 20),
            lockImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Configuração
    
    /// Configura a célula com dados de uma conquista e progresso
    /// - Parameters:
    ///   - achievement: Conquista a exibir
    ///   - progress: Progresso (0-100)
    func configure(with achievement: Achievement, progress: Double) {
        // Configurar ícone
        iconView.image = UIImage(systemName: achievement.icon)
        iconView.tintColor = achievement.isUnlocked ? .systemYellow : .systemGray3
        
        // Configurar textos
        titleLabel.text = achievement.title
        descriptionLabel.text = achievement.description
        
        // Mostrar/ocultar cadeado
        lockImageView.isHidden = achievement.isUnlocked
        
        // Configurar progresso
        if achievement.isUnlocked {
            progressView.progress = 1.0
            progressLabel.text = "Completo!"
            progressLabel.textColor = .systemGreen
        } else {
            progressView.progress = Float(progress / 100.0)
            progressLabel.text = "\(Int(progress))%"
            progressLabel.textColor = .secondaryLabel
        }
        
        // Ajustar aparência conforme estado
        containerView.backgroundColor = achievement.isUnlocked ? .systemGray6 : .systemGray5
        containerView.layer.borderColor = achievement.isUnlocked ? UIColor.systemYellow.cgColor : UIColor.clear.cgColor
        
        // Opacidade reduzida para conquistas bloqueadas
        alpha = achievement.isUnlocked ? 1.0 : 0.6
    }
}