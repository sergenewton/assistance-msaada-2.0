import React from 'react'
import { Link } from 'react-router-dom'
import { CheckCircle, Clock, Mail } from 'lucide-react'

export const AccountPendingPage: React.FC = () => {
  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full">
        {/* Logo et titre */}
        <div className="text-center mb-8">
          <div className="flex justify-center mb-6">
            <div className="w-20 h-20 bg-emerald-500 rounded-2xl flex items-center justify-center">
              <CheckCircle className="h-10 w-10 text-white" />
            </div>
          </div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            Compte créé avec succès !
          </h2>
          <p className="text-sm text-gray-600">
            Assistance Msaada 2.0
          </p>
        </div>

        {/* Contenu principal */}
        <div className="bg-white shadow-lg rounded-lg px-8 py-8 text-center">
          <div className="mb-6">
            <div className="flex justify-center mb-4">
              <div className="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center">
                <Clock className="h-8 w-8 text-yellow-600" />
              </div>
            </div>
            
            <h3 className="text-lg font-semibold text-gray-900 mb-3">
              Votre compte est en attente d'approbation
            </h3>
            
            <p className="text-gray-600 mb-4">
              Votre demande de création de compte a été soumise avec succès. 
              Un administrateur système va examiner votre demande et vous contactera 
              par email une fois votre compte approuvé.
            </p>
            
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
              <div className="flex items-start space-x-3">
                <Mail className="h-5 w-5 text-blue-600 mt-0.5 flex-shrink-0" />
                <div className="text-left">
                  <p className="text-sm font-medium text-blue-900">
                    Prochaines étapes :
                  </p>
                  <ul className="text-sm text-blue-700 mt-1 space-y-1">
                    <li>• Vérifiez votre boîte email régulièrement</li>
                    <li>• L'approbation peut prendre 24-48 heures</li>
                    <li>• Vous recevrez un email de confirmation une fois approuvé</li>
                    <li>• Vous pourrez alors vous connecter à la plateforme</li>
                  </ul>
                </div>
              </div>
            </div>
            
            <div className="text-sm text-gray-500 mb-6">
              <p>
                <strong>Besoin d'aide ?</strong><br />
                Contactez l'équipe support à : 
                <a href="mailto:support@msaada.org" className="text-emerald-600 hover:text-emerald-500 ml-1">
                  support@msaada.org
                </a>
              </p>
            </div>
          </div>

          {/* Actions */}
          <div>
            <Link
              to="/auth/login"
              className="w-full bg-emerald-500 hover:bg-emerald-600 text-white font-medium py-3 px-4 rounded-lg transition-colors focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 inline-block"
            >
              Aller à la page de connexion
            </Link>
          </div>
        </div>

        {/* Note importante */}
        <div className="mt-6 bg-amber-50 border border-amber-200 rounded-lg p-4">
          <p className="text-sm text-amber-700 text-center">
            <strong>Important :</strong> Gardez vos informations de connexion en sécurité. 
            Ne partagez jamais vos identifiants avec qui que ce soit.
          </p>
        </div>
      </div>
    </div>
  )
}