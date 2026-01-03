import UIKit

/// Controlador que apresenta a lista completa de animais disponíveis para adoção
/// Permite visualizar, filtrar e seguir animais
class AnimalListViewController: UIViewController {
    
    // MARK: - Propriedades de Interface
    
    /// Tabela que exibe a lista de animais
    private let tableView = UITableView()
    
    /// Etiqueta mostrada quando não há animais disponíveis
    private let emptyLabel = UILabel()
    
    // MARK: - Propriedades de Dados
    
    /// Array com todos os animais a serem exibidos
    private var animals: [AnimalEntity] = []
    
    // MARK: - Ciclo de Vida
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupConstraints()
        loadAnimals()
        fetchDataFromAPI()	
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Recarregar dados sempre que a vista aparecer
        // (para refletir mudanças feitas noutras vistas)
        loadAnimals()
    }
    
    // MARK: - Configuração da Interface
    
    /// Configura os elementos básicos da interface
    private func setupUI() {
        title = "Animais para Adoção"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Botão de filtros na barra de navegação
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "slider.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )
        
        // Configurar etiqueta de estado vazio
        emptyLabel.text = "Nenhum animal encontrado\n\nToque para recarregar"
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
    }
    
    /// Configura a tabela de animais
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AnimalTableViewCell.self, forCellReuseIdentifier: "AnimalCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .singleLine
        
        view.addSubview(tableView)
    }
    
    /// Configura as restrições de layout para todos os elementos
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Tabela ocupa toda a área disponível
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Etiqueta vazia centrada
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Gestão de Dados
    
    /// Carrega todos os animais da base de dados e actualiza a interface
    private func loadAnimals() {
        animals = CoreDataManager.shared.fetchAllAnimals()
        emptyLabel.isHidden = !animals.isEmpty
        tableView.reloadData()
    }
    
    // MARK: - Acções
    
    /// Chamado quando o botão de filtros é pressionado
    /// Apresenta o controlador de filtros
    @objc private func filterTapped() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        let nav = UINavigationController(rootViewController: filterVC)
        present(nav, animated: true)
    }
    
    // MARK: - Integração API
        
        private func fetchDataFromAPI() {
            // Indicador de atividade na barra de navegação (opcional, mas fica bem)
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.startAnimating()
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(customView: activityIndicator),
                navigationItem.rightBarButtonItem! // Mantém o botão de filtros
            ]
            
            print("📡 A iniciar pedido à API...")
            
            APIService.shared.fetchAnimals { [weak self] success in
                DispatchQueue.main.async {
                    // Parar animação
                    activityIndicator.stopAnimating()
                    
                    // Restaurar botão original
                    self?.navigationItem.rightBarButtonItems = [
                        UIBarButtonItem(
                            image: UIImage(systemName: "slider.horizontal.3"),
                            style: .plain,
                            target: self,
                            action: #selector(self?.filterTapped)
                        )
                    ]
                    
                    if success {
                        print("🔄 Dados recebidos da API. A atualizar tabela...")
                        self?.loadAnimals() // Recarrega os dados do Core Data para a Tabela
                    } else {
                        print("⚠️ Falha ao obter dados da API.")
                    }
                }
            }
        }
}

// MARK: - Data Source da Tabela

extension AnimalListViewController: UITableViewDataSource {
    
    /// Número de linhas na tabela (um animal por linha)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animals.count
    }
    
    /// Configura cada célula com os dados de um animal
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath) as! AnimalTableViewCell
        let animal = animals[indexPath.row]
        cell.configure(with: animal)
        cell.delegate = self
        return cell
    }
}

// MARK: - Delegate da Tabela

extension AnimalListViewController: UITableViewDelegate {
    
    /// Chamado quando uma linha é selecionada
    /// Navega para os detalhes do animal
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let animal = animals[indexPath.row]
        let detailVC = AnimalDetailViewController(animal: animal)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    /// Configura acções de swipe à direita na célula
    /// Permite seguir/deixar de seguir rapidamente
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let animal = animals[indexPath.row]
        
        // Acção de seguir/deixar de seguir
        let followAction = UIContextualAction(
            style: .normal,
            title: animal.isFollowing ? "Deixar de Seguir" : "Seguir"
        ) { _, _, completionHandler in
            CoreDataManager.shared.toggleFollowing(for: animal)
            self.loadAnimals()
            completionHandler(true)
        }
        
        // Cor verde para seguir, laranja para deixar de seguir
        followAction.backgroundColor = animal.isFollowing ? .systemOrange : .systemGreen
        
        let configuration = UISwipeActionsConfiguration(actions: [followAction])
        return configuration
    }
}

// MARK: - Delegate de Filtros

extension AnimalListViewController: FilterViewControllerDelegate {
    
    /// Chamado quando filtros são aplicados
    /// - Parameters:
    ///   - species: Espécie filtrada (opcional)
    ///   - breed: Raça filtrada (opcional)
    ///   - gender: Género filtrado (opcional)
    ///   - age: Idade filtrada (opcional)
    func didApplyFilters(species: String?, breed: String?, gender: String?, age: String?) {
        print("Filtros aplicados: especie=\(species ?? "todas"), raca=\(breed ?? "todas"), genero=\(gender ?? "todos"), idade=\(age ?? "todas")")
        loadAnimals()
    }
}

// MARK: - Delegate da Célula de Animal

extension AnimalListViewController: AnimalTableViewCellDelegate {
    
    /// Chamado quando o botão de favorito é pressionado numa célula
    /// Alterna o estado de seguir do animal
    func animalCellDidTapFavorite(_ cell: AnimalTableViewCell, animal: AnimalEntity) {
        CoreDataManager.shared.toggleFollowing(for: animal)
        loadAnimals()
    }
}
