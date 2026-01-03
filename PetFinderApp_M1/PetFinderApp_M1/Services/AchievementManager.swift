import Foundation
import UIKit

/// Gestor centralizado para o sistema de conquistas
/// Rastreia o progresso do utilizador e desbloqueia conquistas automaticamente
class AchievementManager {
    
    // MARK: - Singleton
    
    static let shared = AchievementManager()
    private init() {}
    
    // MARK: - Keys para UserDefaults
    
    private let appOpenCountKey = "appOpenCount"
    private let unlockedAchievementsKey = "unlockedAchievements"
    
    // MARK: - Definição de Conquistas
    
    enum AchievementType: Int, CaseIterable {
        case firstFollow = 1
        case collector = 2
        case protector = 3
        case champion = 4
        case visitor = 5
        case explorer = 6
        
        var title: String {
            switch self {
            case .firstFollow: return "Primeiro Passo"
            case .collector: return "Colecionador"
            case .protector: return "Protetor"
            case .champion: return "Campeão"
            case .visitor: return "Visitante"
            case .explorer: return "Explorador"
            }
        }
        
        var description: String {
            switch self {
            case .firstFollow: return "Seguir o primeiro animal"
            case .collector: return "Seguir 5 animais"
            case .protector: return "Seguir 10 animais"
            case .champion: return "Seguir 25 animais"
            case .visitor: return "Visitar a app 5 vezes"
            case .explorer: return "Visitar a app 20 vezes"
            }
        }
        
        var icon: String {
            switch self {
            case .firstFollow: return "star.fill"
            case .collector: return "heart.circle.fill"
            case .protector: return "shield.fill"
            case .champion: return "crown.fill"
            case .visitor: return "eye.fill"
            case .explorer: return "map.fill"
            }
        }
        
        var requiredValue: Int {
            switch self {
            case .firstFollow: return 1
            case .collector: return 5
            case .protector: return 10
            case .champion: return 25
            case .visitor: return 5
            case .explorer: return 20
            }
        }
    }
    
    // MARK: - Rastreamento de Métricas
    
    /// Incrementa o contador de aberturas da app
    func incrementAppOpenCount() {
        let currentCount = UserDefaults.standard.integer(forKey: appOpenCountKey)
        let newCount = currentCount + 1
        UserDefaults.standard.set(newCount, forKey: appOpenCountKey)
        
        print("📱 App aberta \(newCount) vezes")
        
        // Verificar conquistas relacionadas com visitas
        checkVisitAchievements()
    }
    
    /// Verifica e desbloqueia conquistas relacionadas com seguir animais
    func checkFollowingAchievements() {
        let followingCount = CoreDataManager.shared.getFollowingCount()
        
        print("❤️ Animais seguidos: \(followingCount)")
        
        // Verificar cada conquista de seguir animais
        if followingCount >= 1 {
            unlockAchievement(.firstFollow)
        }
        if followingCount >= 5 {
            unlockAchievement(.collector)
        }
        if followingCount >= 10 {
            unlockAchievement(.protector)
        }
        if followingCount >= 25 {
            unlockAchievement(.champion)
        }
    }
    
    /// Verifica conquistas relacionadas com visitas à app
    private func checkVisitAchievements() {
        let visitCount = UserDefaults.standard.integer(forKey: appOpenCountKey)
        
        if visitCount >= 5 {
            unlockAchievement(.visitor)
        }
        if visitCount >= 20 {
            unlockAchievement(.explorer)
        }
    }
    
    // MARK: - Gestão de Conquistas
    
    /// Desbloqueia uma conquista se ainda não estiver desbloqueada
    /// - Parameter type: Tipo de conquista a desbloquear
    private func unlockAchievement(_ type: AchievementType) {
        var unlockedAchievements = getUnlockedAchievements()
        
        // Se já está desbloqueada, não fazer nada
        if unlockedAchievements.contains(type.rawValue) {
            return
        }
        
        // Desbloquear conquista
        unlockedAchievements.append(type.rawValue)
        UserDefaults.standard.set(unlockedAchievements, forKey: unlockedAchievementsKey)
        
        print("🏆 Conquista desbloqueada: \(type.title)")
        
        // Mostrar notificação de conquista
        showAchievementNotification(type)
    }
    
    /// Verifica se uma conquista está desbloqueada
    /// - Parameter type: Tipo de conquista
    /// - Returns: true se desbloqueada, false caso contrário
    func isAchievementUnlocked(_ type: AchievementType) -> Bool {
        let unlockedAchievements = getUnlockedAchievements()
        return unlockedAchievements.contains(type.rawValue)
    }
    
    /// Obtém a lista de IDs de conquistas desbloqueadas
    /// - Returns: Array de IDs de conquistas
    private func getUnlockedAchievements() -> [Int] {
        return UserDefaults.standard.array(forKey: unlockedAchievementsKey) as? [Int] ?? []
    }
    
    /// Obtém todas as conquistas com o estado atual
    /// - Returns: Array de Achievement
    func getAllAchievements() -> [Achievement] {
        return AchievementType.allCases.map { type in
            Achievement(
                id: type.rawValue,
                title: type.title,
                description: type.description,
                icon: type.icon,
                isUnlocked: isAchievementUnlocked(type)
            )
        }
    }
    
    /// Obtém o progresso atual para uma conquista
    /// - Parameter type: Tipo de conquista
    /// - Returns: Progresso atual (0 a 100%)
    func getProgress(for type: AchievementType) -> Double {
        let currentValue: Int
        let requiredValue = type.requiredValue
        
        switch type {
        case .firstFollow, .collector, .protector, .champion:
            currentValue = CoreDataManager.shared.getFollowingCount()
        case .visitor, .explorer:
            currentValue = UserDefaults.standard.integer(forKey: appOpenCountKey)
        }
        
        let progress = min(Double(currentValue) / Double(requiredValue), 1.0)
        return progress * 100
    }
    
    /// Obtém estatísticas do utilizador
    func getUserStats() -> (followingCount: Int, visitCount: Int, achievementsUnlocked: Int) {
        let followingCount = CoreDataManager.shared.getFollowingCount()
        let visitCount = UserDefaults.standard.integer(forKey: appOpenCountKey)
        let achievementsUnlocked = getUnlockedAchievements().count
        
        return (followingCount, visitCount, achievementsUnlocked)
    }
    
    // MARK: - Notificações
    
    /// Mostra uma notificação local quando uma conquista é desbloqueada
    /// - Parameter type: Tipo de conquista desbloqueada
    private func showAchievementNotification(_ type: AchievementType) {
        let content = UNMutableNotificationContent()
        content.title = "🏆 Conquista Desbloqueada!"
        content.body = "\(type.title) - \(type.description)"
        content.sound = .default
        
        // Disparar notificação imediatamente
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "achievement_\(type.rawValue)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erro ao mostrar notificação de conquista: \(error)")
            }
        }
    }
    
    // MARK: - Reset (para testes)
    
    /// Limpa todas as conquistas e estatísticas (apenas para desenvolvimento/testes)
    func resetAllAchievements() {
        UserDefaults.standard.removeObject(forKey: unlockedAchievementsKey)
        UserDefaults.standard.removeObject(forKey: appOpenCountKey)
        print("🔄 Todas as conquistas foram resetadas")
    }
}

/// Estrutura que representa uma conquista
struct Achievement {
    let id: Int
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
}