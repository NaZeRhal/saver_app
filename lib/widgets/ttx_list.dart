import 'package:flutter/material.dart';
import 'package:saver_app/models/transaction.dart';
import 'package:saver_app/widgets/transaction_item.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function deleteTransaction;

  const TransactionList(
      {@required this.transactions, @required this.deleteTransaction});

  @override
  Widget build(BuildContext context) {
    print('build() TransactionList');
    return transactions.length == 0
        ? LayoutBuilder(builder: (context, constrainats) {
            return Column(
              children: [
                Text(
                  'No transactions added yet!',
                  style: Theme.of(context).textTheme.title,
                ),
                SizedBox(height: constrainats.maxHeight * 0.05),
                Container(
                  height: constrainats.maxHeight * 0.6,
                  child: Image.asset(
                    'assets/images/budget.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            );
          })
        : ListView.builder(
            itemBuilder: (context, index) {
              return TransactionItem(
                transaction: transactions[index],
                deleteTransaction: deleteTransaction,
              );
            },
            itemCount: transactions.length,
          );
  }
}
