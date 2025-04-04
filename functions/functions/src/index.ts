import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { UserRecord } from 'firebase-admin/auth';

admin.initializeApp();

export const definirTipoConta = functions.auth.user().onCreate(async (user: UserRecord) => {
  try {
    const isPrestador = user.email?.endsWith('@prestador.com') || false;

    await admin.auth().setCustomUserClaims(user.uid, {
      tipo_conta: isPrestador ? 'prestador' : 'cliente',
      conta_completa: false,
    });

    const userData = {
      email: user.email,
      data_criacao: admin.firestore.FieldValue.serverTimestamp(),
    };

    const collection = isPrestador ? 'prestadores' : 'clientes';
    await admin.firestore().collection(collection).doc(user.uid).set(userData);

    return true;
  } catch (error) {
    console.error('Erro ao definir tipo de conta:', error);
    return false;
  }
});
