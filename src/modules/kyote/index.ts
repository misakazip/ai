import { bindThis } from '@/decorators.js';
import Module from '@/module.js';
import Message from '@/message.js';

 // This code is copied from https://gakogako.com/typescript_day_diff/
const formatDate = (date: Date): string => {
    const y: number = date.getFullYear();
    const m: string = ("00" + (date.getMonth() + 1)).slice(-2);
    const d: string = ("00" + date.getDate()).slice(-2);
    return `${y + "-" + m + "-" + d}`;
  };

  const setDate: Date = new Date('2026-01-17');
  const nowDate: Date = new Date(formatDate(new Date()));
  let resWord = "";
  
  const diffDay: number = Math.floor((nowDate.getTime() - setDate.getTime()) / 86400000);
  
export default class extends Module {
	public readonly name = 'kyote';

	@bindThis
	public install() {
		return {
			mentionHook: this.mentionHook
		};
	}

	@bindThis
	private async mentionHook(msg: Message) {
		if (msg.text && msg.text.includes('共テ','共通テスト')) {
			msg.reply('共通テストまで ${Math.abs(diffDay)} 日です', {
				immediate: true
			});
			return true;
		} else {
			return false;
		}
	}
}
