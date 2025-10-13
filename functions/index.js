const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Cloud Function to send follow-up notifications
exports.sendFollowUpNotifications = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    
    // Query leads with follow-ups due
    const leadsSnapshot = await db
      .collection('leads')
      .where('initialFollowUp', '<=', now)
      .where('initialFollowUp', '>', new admin.firestore.Timestamp(now.seconds - 1800, 0)) // Within last 30 minutes
      .get();
    
    for (const doc of leadsSnapshot.docs) {
      const leadData = doc.data();
      
      if (leadData.assignedTo) {
        // Get employee FCM tokens
        const employeeDoc = await db.collection('users').doc(leadData.assignedTo).get();
        if (employeeDoc.exists) {
          const employeeData = employeeDoc.data();
          const fcmTokens = employeeData.fcmTokens || [];
          
          if (fcmTokens.length > 0) {
            const message = {
              notification: {
                title: 'Follow-up Reminder',
                body: `Initial follow-up for ${leadData.clientName} is due now!`,
              },
              data: {
                type: 'follow_up',
                leadId: doc.id,
                clientName: leadData.clientName,
              },
              tokens: fcmTokens,
            };
            
            try {
              await admin.messaging().sendMulticast(message);
              console.log(`Follow-up notification sent for lead: ${doc.id}`);
            } catch (error) {
              console.error('Error sending notification:', error);
            }
          }
        }
      }
    }
  });



