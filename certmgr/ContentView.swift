//
//  ContentView.swift
//  certmgr
//
//  Created by Alfred Eisenberg on 7/16/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

			do {
//				let status = delteSecKey(secKey: )
				let identities = getAllSecIdentitiesFromKeychain()
				let (keyPEMs, certPEMs) = getPEMsFromIdentities(identities: identities)
				let (SecKeys, SecCerts)  = separateSecKeysAndSecCertificates(from: identities)

				if let cert = findCertificateBySerialNumber(serialNumber: "6700629E719ED1E00D6CFB1D8805B573") {
//					dumpCertFromSecCertificate(cert:cert)
				}
				if let cert = findCertificateBySerialNumber(serialNumber: "6700629E719ED1E00D6CFB1D8805B576") {
//					dumpCertFromSecCertificate(cert:cert)
				}
				if let status = deleteCertificateBySerialNumber(serialNumber: "6700629E719ED1E00D6CFB1D8805B573") {
//					dumpCertFromSecCertificate(cert:cert)
				}
				if let status = deleteCertificateBySerialNumber(serialNumber: "6700629E719ED1E00D6CFB1D8805B576") {
//					dumpCertFromSecCertificate(cert:cert)
				}
				if let status = deleteIdentityBySerialNumber(serialNumber: "6700629E719ED1E00D6CFB1D8805B576") {
//					dumpCertFromSecCertificate(cert:cert)
				}

				let keyAttrs = findKeychainItemsAttributes(ksecClass: kSecClassKey as String, labelMatch: nil, exact: false)
				let certAttrs = findKeychainItemsAttributes(ksecClass: kSecClassCertificate as String, labelMatch: nil, exact: false)
				let identityAttrs = findKeychainItemsAttributes(ksecClass: kSecClassIdentity as String, labelMatch: nil, exact: false)
				let keyAttrsFiltered = findKeychainItemsAttributes(ksecClass: kSecClassKey as String, labelMatch: "Invisinet", exact: false)
				let certAttrsFiltered = findKeychainItemsAttributes(ksecClass: kSecClassCertificate as String, labelMatch: "invisinet", exact: false)
				let keyDataFiltered = findKeychainItemsData(ksecClass: kSecClassKey as String, labelMatch: "com.invisinet.key.5577FEC4-81F8-40AA-8366-041205C6AB08", exact: true)
				let certDataFiltered = findKeychainItemsData(ksecClass: kSecClassCertificate as String, labelMatch: "invisinet", exact: false)
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
