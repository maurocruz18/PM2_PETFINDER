import UIKit

protocol FilterViewControllerDelegate: AnyObject {

    func didApplyFilters(gender: String?, age: String?)
}

class FilterViewController: UIViewController {
    
    weak var delegate: FilterViewControllerDelegate?
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Filtrar Resultados"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    // Selector de Género
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "Género"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let genderSegmentedControl: UISegmentedControl = {
        let items = ["Todos", "Macho", "Fêmea"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    // Selector de Idade
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.text = "Idade"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let ageSegmentedControl: UISegmentedControl = {
        
        let items = ["Todos", "Young", "Adult", "Senior"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Aplicar Filtros", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        // StackView para organizar tudo verticalmente
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            createSpacer(height: 20),
            genderLabel,
            genderSegmentedControl,
            createSpacer(height: 20),
            ageLabel,
            ageSegmentedControl,
            createSpacer(height: 40),
            applyButton
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Altura do botão
        applyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Ação do botão
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
    }
    
    private func createSpacer(height: CGFloat) -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
    
    // MARK: - Actions
    
    @objc private func applyTapped() {
        // 1. Ler Género
        var selectedGender: String? = nil
        if genderSegmentedControl.selectedSegmentIndex == 1 {
            selectedGender = "Macho"
        } else if genderSegmentedControl.selectedSegmentIndex == 2 {
            selectedGender = "Fêmea"
        }
        
        // 2. Ler Idade
        var selectedAge: String? = nil
        let ageIndex = ageSegmentedControl.selectedSegmentIndex
        if ageIndex > 0 { // 0 é "Todos"
            selectedAge = ageSegmentedControl.titleForSegment(at: ageIndex)
        }
        
        // 3. Enviar para o Delegate
        delegate?.didApplyFilters(gender: selectedGender, age: selectedAge)
        dismiss(animated: true)
    }
}
