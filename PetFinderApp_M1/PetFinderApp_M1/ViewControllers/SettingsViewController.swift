import UIKit

class SettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    private func setupUI() {
        title = "Definições"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        tableView.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2 // Cache e Paginação
        case 1: return 2 // Notificações e Hora
        case 2: return 2 // Geral: Tema e Limpar Dados <--- MUDOU DE 1 PARA 2
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        
        // Reset cell
        cell.textLabel?.text = ""
        cell.detailTextLabel?.text = ""
        cell.accessoryType = .none
        cell.textLabel?.textColor = .label
        
        switch indexPath.section {
        case 0: // Cache
            if indexPath.row == 0 {
                cell.textLabel?.text = "Expiração de Cache"
                let minutes = UserDefaults.standard.integer(forKey: "cacheExpirationMinutes")
                cell.detailTextLabel?.text = "\(minutes > 0 ? minutes : 60) minutos"
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.textLabel?.text = "Animais por página"
                let items = UserDefaults.standard.integer(forKey: "itemsPerPage")
                cell.detailTextLabel?.text = "\(items > 0 ? items : 20) itens"
                cell.accessoryType = .disclosureIndicator
            }
            
        case 1: // Notificações
            if indexPath.row == 0 {
                cell.textLabel?.text = "Notificações Diárias"
                let isEnabled = UserDefaults.standard.bool(forKey: "dailyNotificationsEnabled")
                cell.accessoryType = isEnabled ? .checkmark : .none
            } else {
                cell.textLabel?.text = "Hora Preferencial"
                let hour = UserDefaults.standard.integer(forKey: "notificationHour")
                cell.detailTextLabel?.text = String(format: "%02d:00", hour > 0 ? hour : 9)
                cell.accessoryType = .disclosureIndicator
            }
            
        case 2: // Geral
            if indexPath.row == 0 {
                // --- NOVO: TEMA ---
                cell.textLabel?.text = "Tema da Aplicação"
                let theme = UserDefaults.standard.string(forKey: "appTheme") ?? "Sistema"
                cell.detailTextLabel?.text = theme
                cell.accessoryType = .disclosureIndicator
            } else {
                // Limpar Dados
                cell.textLabel?.text = "Limpar Todos os Dados"
                cell.textLabel?.textColor = .systemRed
            }
            
        default: break
        }
        
        return cell
    }
}
    
    

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                showCacheExpirationPicker()
            } else {
                showItemsPerPagePicker()
            }
            
        case 1:
            if indexPath.row == 0 {
                toggleNotifications()
            } else {
                showNotificationTimePicker()
            }
            
        case 2:
                if indexPath.row == 0 {
                    showThemePicker() // <--- NOVO
                } else {
                    clearAllData()
                }
        default:
            clearAllData()
        }
        
        
    }
    
    private func showThemePicker() {
            let alert = UIAlertController(title: "Tema", message: "Escolha a aparência", preferredStyle: .actionSheet)
            
            let themes = ["Sistema", "Claro", "Escuro"]
            
            for theme in themes {
                alert.addAction(UIAlertAction(title: theme, style: .default) { _ in
                    // 1. Guardar preferência
                    UserDefaults.standard.set(theme, forKey: "appTheme")
                    
                    // 2. Aplicar imediatamente
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        
                        switch theme {
                        case "Claro": window.overrideUserInterfaceStyle = .light
                        case "Escuro": window.overrideUserInterfaceStyle = .dark
                        default: window.overrideUserInterfaceStyle = .unspecified
                        }
                    }
                    
                    // 3. Atualizar Tabela
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
                })
            }
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            present(alert, animated: true)
        }
    
    // MARK: - Actions
    
    private func showCacheExpirationPicker() {
        let alert = UIAlertController(title: "Expiração de Cache", message: "Selecione em minutos", preferredStyle: .actionSheet)
        
        let options = [30, 60, 120, 240, 480]
        for option in options {
            alert.addAction(UIAlertAction(title: "\(option) minutos", style: .default) { _ in
                UserDefaults.standard.set(option, forKey: "cacheExpirationMinutes")
                self.tableView.reloadSections([0], with: .automatic)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showItemsPerPagePicker() {
        let alert = UIAlertController(title: "Animais por Página", message: "Selecione quantos itens", preferredStyle: .actionSheet)
        
        let options = [10, 20, 50, 100]
        for option in options {
            alert.addAction(UIAlertAction(title: "\(option) itens", style: .default) { _ in
                UserDefaults.standard.set(option, forKey: "itemsPerPage")
                self.tableView.reloadSections([0], with: .automatic)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    private func toggleNotifications() {
        let currentValue = UserDefaults.standard.bool(forKey: "dailyNotificationsEnabled")
        UserDefaults.standard.set(!currentValue, forKey: "dailyNotificationsEnabled")
        
        if !currentValue {
            // Enable notifications
            let hour = UserDefaults.standard.integer(forKey: "notificationHour")
            NotificationService.shared.scheduleDailyAnimalNotification(at: hour > 0 ? hour : 9)
            
            // Show success message
            let alert = UIAlertController(title: "Notificações Ativadas", message: "Receberá notificações diárias", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            // Disable notifications
            NotificationService.shared.cancelNotification(identifier: "dailyAnimal")
        }
        
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
    }
    
    private func showNotificationTimePicker() {
        let alert = UIAlertController(title: "Hora Preferencial", message: nil, preferredStyle: .actionSheet)
        
        for hour in 0..<24 {
            let timeString = String(format: "%02d:00", hour)
            alert.addAction(UIAlertAction(title: timeString, style: .default) { _ in
                UserDefaults.standard.set(hour, forKey: "notificationHour")
                
                // Reschedule notification if enabled
                if UserDefaults.standard.bool(forKey: "dailyNotificationsEnabled") {
                    NotificationService.shared.scheduleDailyAnimalNotification(at: hour)
                }
                
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .automatic)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    private func clearAllData() {
        let alert = UIAlertController(
            title: "Limpar Dados",
            message: "Tem certeza que deseja limpar todos os dados? Esta ação não pode ser desfeita.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Limpar", style: .destructive) { _ in
            CoreDataManager.shared.deleteAllAnimals()
            
            let successAlert = UIAlertController(
                title: "Sucesso",
                message: "Todos os dados foram eliminados.",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(successAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
}
